# conf.py

import os
import sys
sys.path.insert(0, os.path.abspath('.'))

# Project information
project = 'Circles'
author = 'AboutCircles'
release = '0.3.4'

# General configuration
extensions = [
    'sphinx.ext.autodoc',
    'sphinx.ext.napoleon',
    'sphinx.ext.viewcode',
]

templates_path = ['_templates']
exclude_patterns = []

# Options for HTML output
html_theme = 'alabaster'
html_static_path = ['_static']

# Add Solidity docgen output path
solidity_docgen_output = os.path.abspath('solidity')
