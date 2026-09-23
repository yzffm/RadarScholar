"""Allow running crawler as: python -m app.crawler"""

import sys

from app.crawler.main import main

sys.exit(main())
