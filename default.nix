{ buildPythonPackage

, black
, pylint

, ipython
, sphinx
, sphinx_rtd_theme

, pytest

, scipy
, xarray
}:

let
  # Development tools used during package build
  nativeBuildInputs = [
    black
    pylint
  ] ++ [ # Documentation
    ipython
    sphinx
    sphinx_rtd_theme
  ];

  # Run-time Python dependencies
  propagatedBuildInputs = [
    scipy
    xarray
  ];

  # Test-dependencies
  checkInputs = [
    pytest
  ];

  allInputs = nativeBuildInputs ++ propagatedBuildInputs ++ checkInputs;

  pkg = buildPythonPackage {
    pname = "xrscipy";
    version = "dev";
    format = "setuptools";

    src = ./.;

    inherit nativeBuildInputs propagatedBuildInputs checkInputs;

    preBuild = ''
      echo "Checking for errors with pylint..."
      # waiting for https://github.com/PyCQA/astroid/pull/733
      #pylint -E xrscipy
    '';

    postInstall = ''
      echo "Checking formatting..."
      black --check xrscipy

      #echo "Creating html docs..."
      #make -C doc html
      #mkdir -p $out
      #mv doc/build/html $doc
    '';

    checkPhase = ''
      pytest xrscipy/tests
    '';

    doCheck = true;

    shellHook = ''
      export PYTHONPATH="$(pwd):"$PYTHONPATH""
    '';

    outputs = [
      "out"
      "doc"
    ];

    passthru = {
      inherit allInputs;
    };
  };

in pkg
