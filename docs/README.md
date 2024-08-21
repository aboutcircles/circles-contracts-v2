# Protocol Documentation

This directory contains the documentation for the protocol using MkDocs.

## Prerequisites

- Miniconda or Anaconda installed on your system. If you don't have it installed, you can download and install it from the [official website](https://docs.conda.io/en/latest/miniconda.html).

## Setup

1. Open a terminal or command prompt and navigate to the `docs/` directory.

2. Create a new conda environment named "protocol-docs" with Python 3.9:
   ```bash
   conda create --name protocol-docs python=3.9
   conda activate protocol-docs
   ```

3. Install MkDocs and its dependencies from the `conda-forge` channel:
   ```bash
   conda install -c conda-forge --file requirements.txt
   ```

4. Verify the installation by running:
   ```bash
   mkdocs --version
   ```

## Usage

1. Ensure you have activated the "protocol-docs" environment:
   ```bash
   conda activate protocol-docs
   ```

2. Preview the documentation locally:
   ```bash
   mkdocs serve
   ```
   Open a web browser and navigate to `http://localhost:8000` to view the documentation.

3. Build the documentation:
   ```bash
   mkdocs build
   ```
   The static HTML files will be generated in the `site/` directory.

4. Deploy the documentation:
   - Copy the contents of the `site/` directory to your preferred hosting platform or server.
   - Configure your hosting platform to serve the files from the `site/` directory.

## Adding Documentation

- Create new Markdown files in the `docs/` directory for each documentation page.
- Update the `mkdocs.yml` file to include the new pages in the navigation structure.

## Updating Dependencies

If you need to update the dependencies or install additional packages, follow these steps:

1. Update the `requirements.txt` file with the desired dependencies.

2. Activate the "protocol-docs" environment:
   ```bash
   conda activate protocol-docs
   ```

3. Update the dependencies using conda and the `conda-forge` channel:
   ```bash
   conda install -c conda-forge --file requirements.txt
   ```

## Deactivating the Environment

When you're done working on the documentation, you can deactivate the "protocol-docs" environment:

```bash
conda deactivate
```