# The web app and CLI of `firefly-importer-ing`, see the aspect in
# `modules/services/firefly-importer-ing [N]/`. The Python dependencies come
# from nixpkgs; `pyproject.toml` lists the same ones for `uv run`.
{
  lib,
  python3Packages,
  tailwindcss_4,
  postgresql,
  postgresqlTestHook,
}:
python3Packages.buildPythonApplication {
  pname = "firefly-importer-ing";
  version = "0.1.0";
  pyproject = true;

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./alembic.ini
      ./pyproject.toml
      ./src
      ./tests
    ];
  };

  build-system = [python3Packages.hatchling];

  dependencies = with python3Packages; [
    alembic
    cryptography
    flask
    flask-wtf
    gunicorn
    itsdangerous
    psycopg
    requests
    sqlalchemy
  ];

  # The stylesheet holds only the classes the templates use
  preBuild = ''
    ${lib.getExe tailwindcss_4} --minify \
      --input src/firefly_importer_ing/static/input.css \
      --output src/firefly_importer_ing/static/app.css
  '';

  # The web tests run against a throwaway PostgreSQL
  nativeCheckInputs = [
    python3Packages.pytestCheckHook
    postgresql
    postgresqlTestHook
  ];
  env.PGDATABASE = "firefly_importer_ing_test";
  env.PGUSER = "firefly_importer_ing_test";

  pythonImportsCheck = ["firefly_importer_ing"];

  meta = {
    description = "Convert ING exports and import them into Firefly III";
    mainProgram = "firefly-importer-ing-serve";
  };
}
