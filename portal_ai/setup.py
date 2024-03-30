import setuptools


def readme():
    with open('README.md', encoding='utf8') as f:
        README = f.read()
    return README


requirements = []
with open('requirements.txt') as f:
    for line in f.read().splitlines():
        if line.startswith('# extras'):
            break
        requirements.append(line)

setuptools.setup(
    name='portal-ai',
    version='0.0.1',
    author='Schlafdata',
    author_email='john@schlafdata.com',
    description='Portal-AI is a tool for deploying AWS infrastructure to run GPU accelerated workflows and websites for LLMs.',
    long_description=readme(),
    long_description_content_type='text/markdown',
    url='https://github.com/portal-ai/portal_ai',
    packages=setuptools.find_packages('.'),
    include_package_data=True,
    classifiers=[
        'Programming Language :: Python :: 3',
        'Operating System :: MacOS',
    ],
    install_requires=requirements,
    python_requires='>=3.10',
)