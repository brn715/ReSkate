APP_NAME   := ReSkate
BIN        := reskate-launcher
BUILD      := .build/debug
APP_DIR    := $(APP_NAME).app
CONTENTS   := $(APP_DIR)/Contents
MACOS_DIR  := $(CONTENTS)/MacOS
RES_DIR    := $(CONTENTS)/Resources

.PHONY: app run clean

app: $(APP_DIR)

$(APP_DIR): $(BUILD)/$(BIN) $(CONTENTS)/Info.plist
	@mkdir -p $(MACOS_DIR) $(RES_DIR)
	@cp $(BUILD)/$(BIN) $(MACOS_DIR)/$(APP_NAME)
	@chmod +x $(MACOS_DIR)/$(APP_NAME)
	@echo "Built $(APP_DIR)"

$(CONTENTS)/Info.plist: Info.plist.in
	@mkdir -p $(CONTENTS)
	@cp Info.plist.in $@

$(BUILD)/$(BIN):
	@swift build

run: app
	@open $(APP_DIR)

clean:
	@rm -rf $(APP_DIR) .build
