"""Book Hub processing worker.

Claims document processing jobs from the API database and runs the
extraction pipeline. Planned stages: classifier -> extractor -> normalizer
-> scorer.
"""

__version__ = "0.1.0"