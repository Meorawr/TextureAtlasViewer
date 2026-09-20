set shell := ["bash", "-c"]

PACKAGER_URL := "https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh"
SCHEMA_URL := "https://raw.githubusercontent.com/Meorawr/wow-ui-schema/main/UI.xsd"

default: data

data:
    pwsh Scripts/Generate-Atlases.ps1

check:
    @luacheck -q $(git ls-files '*.lua')
    @xmllint --schema <(curl -s {{SCHEMA_URL}}) --noout $(git ls-files '*.xml')

dist:
    @curl -s {{PACKAGER_URL}} | bash -s -- -dl

libs:
    @curl -s {{PACKAGER_URL}} | bash -s -- -cdz
    @mkdir -p Libs/
    @cp -a .release/TextureAtlasViewer/Libs/* Libs/

