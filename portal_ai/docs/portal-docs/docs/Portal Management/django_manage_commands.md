# Django Management Commands

## update_nav_cmd.py

The `update_nav_cmd.py` script is part of Django's custom management command utility. It is used to import data from a YAML file to the Django models `SidebarItem` and `SidebarSubItem`.

### Overview 

This script first deletes all previous entries in the `SidebarItem` and `SidebarSubItem` models. It then reads from a YAML file, parses the data, and creates new entries in those models. 

### Key Components

- **YAML file:** The input file in YAML format that stores the navigation bar details. It consists of main items and sub-items.
- **SidebarItem model:** This Django model is used to store the main items in the navigation bar.
- **SidebarSubItem model:** This Django model is used to store the sub-items of the main items.

```python
class Command(BaseCommand):
    help = 'Import data from YAML file'

    def handle(self, *args, **options):
        # Code here
```

The `handle` method is where the logic of the script is implemented.

## update_docs.py

The `update_docs.py` script is also part of Django's custom management command utility. It is used for building and updating a static docs site from a Docasaurus doc hub.

### Overview

This script navigates to the doc hub directory, builds the documentation, and then copies the generated build to the static directory.

### Key Components

- **Docasaurus doc hub:** It is a tool used for creating, maintaining, and publishing documentation for your project.
- **Build command:** It's a command that runs the npm build script, which generates a build of the documentation.
- **Static directory:** The directory where the built documentation is placed after it's generated.

```python
class Command(BaseCommand):
    help = 'Build and update static docs site from Docasaurus doc_hub.'

    def handle(self, *args, **options):
        # Code here
```

The `handle` method is where the logic of the script is implemented.

## Usage

To use these commands, run the following in your terminal:

For `update_nav_cmd.py`:

```bash
python manage.py update_nav_cmd
```

For `update_docs.py`:

```bash
python manage.py update_docs
```

> Note: Ensure that your Django project is set up correctly and the paths to the files are accurate.