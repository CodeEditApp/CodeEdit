
# Check if the FISH_CONFIG_DIR is set and if the config.fish exists
if test -n "$USER_CONFIG_DIR" -a -f "$USER_CONFIG_DIR/config.fish"
    set CE_CONFIG_DIR $FISH_CONFIG_DIR
    set FISH_CONFIG_DIR $USER_CONFIG_DIR
    
    # Source the user's config.fish
    . "$USER_CONFIG_DIR/config.fish"
    
    # Restore the original FISH_CONFIG_DIR
    set FISH_CONFIG_DIR $CE_CONFIG_DIR
end

# Additional integration functions can go here
