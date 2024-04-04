import os
import sys
import argparse

def should_ignore(item):

    # Define patterns or specific filenames to ignore
    ignored_patterns = [ '.terraform', 
                         '.dbt', 
                         'dbt_packages', 
                         '.databricks', 
                         '.git', 
                         '.js',
                         '.pyc',
                         '.scss',
                         '__pycache__',
                         '__init__.py',
                         '.html',
                         '.ts',
                         '.map',
                         '.svg',
                         '.png',
                         '.css',
                         '.tsx',
                         '.json',
                         '.xml',
                         '.md',
                         '.jpeg',
                         '.mdx'
    ]

    # Ignore items starting with '.'
    if item.startswith('.'):
        return True
    # Ignore specific patterns
    for pattern in ignored_patterns:
        if item.startswith(pattern):
            return True
        elif item.endswith(pattern):
            return True
    return False


def write_tree( directory, 
                prefix='', 
                is_last=True, 
                level=-1, 
                file=None ):
    
    if level == -1:
        file.write(directory.split(os.sep)[-1] + '\n')
        prefix = ''
    else:
        file.write(prefix + ('└── ' if is_last else '├── ') + os.path.basename(directory) + '\n')
    prefix += '    ' if is_last else '│   '
    items = [item for item in sorted(os.listdir(directory)) if not should_ignore(item)]
    for i, item in enumerate(items):
        path = os.path.join(directory, item)
        if os.path.isdir(path):
            write_tree(path, prefix, i == len(items) - 1, level + 1, file)
        else:
            file.write(prefix + ('└── ' if i == len(items) - 1 else '├── ') + item + '\n')

def generate_directory_tree(directory_path, output_file_path):
    with open(output_file_path, 'w') as file:
        write_tree(directory_path, file=file)


def parse_arguments():
    parser = argparse.ArgumentParser(description="Generate Directory Tree md file for documentation.")

    parser.add_argument(
        "-d", "--directory", help="directory you want a tree for.", default=None
    )

    args = parser.parse_args()
    return args


if __name__ == "__main__":

    args = parse_arguments()

    dir = args.directory
    directory_path = f"{os.getcwd()}/{dir}"  # Replace with your target directory path
    dir_clean = '.'.join(dir.split('/'))
    output_file_path = f'portal_ai/documentation/folder_trees/{dir_clean}_tree.md'  # Replace with your output markdown file path
    # Make sure to clear the output file before writing to it
    open(output_file_path, 'w').close()
    generate_directory_tree(directory_path, output_file_path)