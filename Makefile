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

data: Data_Dragonflight.lua Data_Vanilla.lua Data_Wrath.lua Data.lua

Data_Dragonflight.lua: .FORCE
	pwsh Scripts/Generate-Atlases.ps1 -Product wow_beta > $@

Data_Vanilla.lua: .FORCE
	pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic_era > $@

Data_Wrath.lua: .FORCE
	pwsh Scripts/Generate-Atlases.ps1 -Product wow_classic > $@

Data.lua: .FORCE
	pwsh Scripts/Generate-Atlases.ps1 -Product wow > $@
