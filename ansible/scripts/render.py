"""Processes many templates in bulk writing to given path.
Resolve slow processing speed when using `ansible.builtin.template` in loop.
Usage:
    - name: Render tree
      ansible.builtin.command:
        argv:
          - "{{ ansible_playbook_python }}"
          - "scripts/render.py"
        stdin: >-
          {{
            {
               'dest': quadlets_tmp_stage.path,
               'library_roots': [role_path ~ '/templates/containers'],
               'files': quadlet_files | map(attribute='path') | list,
               'opts': {
                 'block_start_string': '[%',
                 'block_end_string': '%]',
                 'variable_start_string': '[[',
                 'variable_end_string': ']]'
               },
               'context': {
                 'containers': containers,
                 'dst_containers_dir': dst_containers_dir
               }
             } | to_json
          }}
"""

import json
import os
import sys
import typing
from dataclasses import dataclass, field
from pathlib import Path

from jinja2 import Environment, FileSystemLoader, StrictUndefined


@dataclass
class Config:
    """
    Jinja2 configuration.
    """

    # where to write rendered.
    dest: Path
    # where template files are.
    library_roots: list[Path]
    # templates itself, without the root part.
    files: list[str]
    # jinja Environment options.
    opts: dict[str, typing.Any] = field(default_factory=dict)
    # rendering context.
    context: dict[str, typing.Any] = field(default_factory=dict)

    @classmethod
    def from_json(cls, value: str) -> "Config":
        return cls(**json.loads(value))

    def __post_init__(self):
        self.dest = Path(self.dest)
        self.library_roots = [Path(p) for p in self.library_roots]


def main() -> int:
    conf = Config.from_json(sys.stdin.read())
    env = Environment(
        loader=FileSystemLoader(conf.library_roots),
        undefined=StrictUndefined,
        keep_trailing_newline=True,
        **conf.opts,
    )
    for f in conf.files:
        dest = conf.dest / f
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_text(env.get_template(f).render(conf.context))
        os.chmod(dest, 0o644)
    return 0


if __name__ == "__main__":
    sys.exit(main())
