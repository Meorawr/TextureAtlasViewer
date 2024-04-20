SHELL := /bin/bash
LIBDIR := Libs
PACKAGER_URL := https://raw.githubusercontent.com/BigWigsMods/packager/master/release.sh
SCHEMA_URL := https://raw.githubusercontent.com/Meorawr/wow-ui-schema/main/UI.xsd

.PHONY: check data dist libs
.FORCE:

all: check data

check:
	@luacheck -q $(shell git ls-files '*.lua')
	@xmllint --schema <(curl -s $(SCHEMA_URL)) --noout $(shell git ls-files '*.xml')

dist:
	@curl -s $(PACKAGER_URL) | bash -s -- -d -l

libs:
	@curl -s $(PACKAGER_URL) | bash -s -- -c -d -z
	@mkdir -p Libs/
	@cp -a .release/TextureAtlasViewer/Libs/* Libs/

data: wow wow_classic wow_classic_era

wow_classic: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data_Cata.lua

wow_classic_beta: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data_Cata.lua

wow_classic_ptr: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data_Cata.lua

wow_classic_era: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data_Vanilla.lua

wow_classic_era_ptr: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data_Vanilla.lua

wow: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data.lua

wow_beta: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data.lua

wowt: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data.lua

wowxptr: deps
	pwsh Scripts/Generate-Atlases.ps1 -Product $@ >Data.lua
