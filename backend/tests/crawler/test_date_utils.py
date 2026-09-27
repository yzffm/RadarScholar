from app.crawler.date_utils import extract_contextual_deadline


def test_date_without_deadline_context_is_not_guessed():
    assert extract_contextual_deadline("Program dimulai 31 Desember 2028") is None


def test_deadline_context_is_selected_over_later_program_date():
    result = extract_contextual_deadline(
        "Pendaftaran sampai 30 September 2027. Program dimulai 31 Desember 2028."
    )
    assert result is not None
    assert result.year == 2027
    assert result.month == 9
