@ECHO OFF

rem Batch script to bundle the stakingdeposit_proxy application and the associated required files on
rem Windows.

SET BATDIR=%~dp0

SET EDCDIR=ethstaker-deposit-cli-0.5.0

SET TARGETPACKAGESPATH=%BATDIR%..\..\dist\packages

SET ETH2DEPOSITCLIPATH=%BATDIR%..\vendors\%EDCDIR%
SET ETH2REQUIREMENTSPATH=%ETH2DEPOSITCLIPATH%\requirements.txt

SET PYTHONPATH=
FOR /F "tokens=* USEBACKQ delims=;" %%F IN (`python -c "import sys;print(';'.join(sys.path))"`) DO (SET PYTHONPATH=%TARGETPACKAGESPATH%;%ETH2DEPOSITCLIPATH%;;%%F)

SET DISTBINPATH=%BATDIR%..\..\build\bin
SET DISTWORDSPATH=%BATDIR%..\..\build\word_lists
SET SRCWORDSPATH=%BATDIR%..\vendors\%EDCDIR%\ethstaker_deposit\key_handling\key_derivation\word_lists
SET SRCINTLPATH=%BATDIR%..\vendors\%EDCDIR%\ethstaker_deposit\intl

mkdir %DISTBINPATH% > nul 2> nul
mkdir %DISTWORDSPATH% > nul 2> nul
mkdir %TARGETPACKAGESPATH% > nul 2> nul

rem Getting all the requirements
python -m pip install -r %ETH2REQUIREMENTSPATH% --target %TARGETPACKAGESPATH%

rem Getting packages metadata
SET PYECCDATA=
FOR /F "tokens=*" %%g IN (`python -c "from PyInstaller.utils.hooks import copy_metadata;print(':'.join(copy_metadata('py_ecc')[0]))"`) do (SET PYECCDATA=%%g)
SET SSZDATA=
FOR /F "tokens=*" %%g IN (`python -c "from PyInstaller.utils.hooks import copy_metadata;print(':'.join(copy_metadata('ssz')[0]))"`) do (SET SSZDATA=%%g)

rem Bundling Python stakingdeposit_proxy
pyinstaller --onefile --distpath %DISTBINPATH% --add-data "%SRCINTLPATH%;ethstaker_deposit\intl" --add-data "%PYECCDATA%" --add-data "%SSZDATA%" -p %PYTHONPATH% %BATDIR%stakingdeposit_proxy.py

rem Adding word list
copy /Y %SRCWORDSPATH%\* %DISTWORDSPATH%
