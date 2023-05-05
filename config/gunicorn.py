import os
import multiprocessing

bind = os.getenv('WEB_BIND', '0.0.0.0:8000')
accesslog = '-'

workers = int(os.getenv('WEB_CONCURRENCY', multiprocessing.cpu_count() * 2))
threads = int(os.getenv('PYTHON_MAX_THREADS', 1))