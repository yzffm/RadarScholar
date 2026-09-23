from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.auth.dependencies import get_current_user
from app.auth.models import AuthUser
from app.database.session import get_db
from app.matching.service import MatchingService
from app.scholarships import service as scholarship_service
from app.users.service import get_profile

from app.ai.schemas import MatchExplanation, AssistantRequest, AssistantResponse
from app.ai.service import AIService, AIUnavailableError
from app.ai.tasks.explanation import ExplanationTask
from app.ai.tasks.assistant import ApplicationAssistantTask
from app.applications.service import ApplicationService

router = APIRouter(prefix="/scholarships", tags=["AI"])
applications_router = APIRouter(prefix="/applications", tags=["AI Assistant"])

# Keep a single instance of AIService across requests
ai_service_instance = AIService()

def get_ai_service() -> AIService:
    return ai_service_instance

@router.get("/{scholarship_id}/ai-explanation", response_model=MatchExplanation)
async def get_scholarship_ai_explanation(
    scholarship_id: UUID,
    db: Session = Depends(get_db),
    user: AuthUser = Depends(get_current_user),
    ai_service: AIService = Depends(get_ai_service),
):
    """
    Generate an AI explanation for why the authenticated user's profile
    matches (or doesn't match) the specified scholarship.
    
    This acts as an enhancement over the deterministic MatchResult.
    """
    profile = get_profile(db, user)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profil pengguna belum dilengkapi."
        )

    scholarship = scholarship_service.get_scholarship(db=db, id=scholarship_id)
    if not scholarship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Scholarship not found",
        )

    # Calculate deterministic match
    matching_service = MatchingService()
    match_res = matching_service.match(profile, scholarship)

    # Use AI to explain the deterministic match
    task = ExplanationTask(ai_service)
    
    try:
        explanation = await task.execute(profile, scholarship, match_res)
        return explanation
    except AIUnavailableError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan saat membuat penjelasan AI.",
        )

@applications_router.post("/{application_id}/ai-assistant", response_model=AssistantResponse)
async def generate_ai_assistant_feedback(
    application_id: UUID,
    request: AssistantRequest,
    db: Session = Depends(get_db),
    user: AuthUser = Depends(get_current_user),
    ai_service: AIService = Depends(get_ai_service),
):
    """
    Generate an AI application assistant feedback based on the user's profile,
    tracked application, scholarship details, and an optional draft text.
    """
    profile = get_profile(db, user)
    if not profile:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Profil pengguna belum dilengkapi."
        )

    # Re-use ApplicationService to handle ownership and fetching securely
    application_service = ApplicationService(db)
    
    # get_application enforces ownership internally (it checks current_user_id)
    try:
        application = application_service.get_application(application_id, user.id)
    except HTTPException:
        # Re-raise if it's already an HTTP Exception (e.g. 404 from get_application)
        raise
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )
        
    if not application:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Application not found"
        )
        
    # The application model should have the related scholarship.
    # We will use the response schemas to pass to the task.
    from app.scholarships.schemas import ScholarshipResponse
    from app.applications.schemas import ApplicationResponse
    
    scholarship = scholarship_service.get_scholarship(db=db, id=application.scholarship_id)
    if not scholarship:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Scholarship not found",
        )
        
    app_response = ApplicationResponse.model_validate(application)
    
    # Use AI to generate feedback
    task = ApplicationAssistantTask(ai_service)
    
    try:
        feedback = await task.execute(profile, scholarship, app_response, request.task_type, request.draft_text)
        return feedback
    except AIUnavailableError as e:
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail=str(e),
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Terjadi kesalahan saat memproses asisten AI.",
        )
