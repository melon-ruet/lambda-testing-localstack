import argparse
from pipenv.project import Project
from pipenv.utils import convert_deps_to_pip


def _make_requirements_file(file_path):
    pipfile = Project(chdir=False).parsed_pipfile

    requirements = convert_deps_to_pip(pipfile['packages'], r=False)
    with open(file_path, 'w') as req_file:
        req_file.write('\n'.join(requirements))


def run():
    parser = argparse.ArgumentParser()
    parser.add_argument(
         '--file_path',
         '-file_path',
         type=str,
         default='requirements.txt'
    )
    args = parser.parse_args()
    _make_requirements_file(args.file_path)


if __name__ == "__main__":
    run()
