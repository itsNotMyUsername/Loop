#!/bin/bash
#
# apply-loop-config.sh
#
# Applies one Loop configuration to this Mac:
#   - 13 radial menu segments (a 3 x 2 grid of thirds and halves)
#   - 12 keybinds, including trigger + left + right = full-height center cycle
#   - the "Allow radial menu customization" flag
#
# All other Loop settings on this Mac stay as they are.
# The current preferences are saved to the Desktop first.
#
# Usage:  bash apply-loop-config.sh
#
set -euo pipefail

DOMAIN="com.MrKai77.Loop"
APP="/Applications/Loop.app"
BACKUP="$HOME/Desktop/loop-prefs-backup-$(date +%Y%m%d-%H%M%S).plist"
WORK="$(mktemp -d)"
trap "rm -rf \"$WORK\"" EXIT

echo "==> Loop configuration"

# --- The configuration data ---------------------------------------------------

cat > "$WORK/radial.txt" << "RADIAL_EOF"
{"id":"32911CAA-7AC3-4092-B3BD-22062361A0C3","type":{"custom":{"_0":{"direction":"Cycle","id":"4531BDDE-1B69-40A4-8538-E446C01E071A","keybind":[],"name":"Top Center","cycle":[{"direction":"Custom","id":"ADC240F4-D53F-4C18-A8EF-D52631399C85","keybind":[],"name":"Top Center Third","unit":1,"positionMode":1,"sizeMode":0,"xPoint":33.333,"yPoint":0,"width":33.334,"height":50},{"direction":"Custom","id":"C145D0FE-3974-4675-800B-04467001C690","keybind":[],"name":"Top Center Half","unit":1,"positionMode":1,"sizeMode":0,"xPoint":25,"yPoint":0,"width":50,"height":50},{"direction":"Custom","id":"3B8875A8-AA0F-421F-AB8E-D565DEDC7DC9","keybind":[],"name":"Top Center Two Thirds","unit":1,"positionMode":1,"sizeMode":0,"xPoint":16.667,"yPoint":0,"width":66.666,"height":50}]}}}}
{"id":"ACB3CA4B-E1DB-44B8-9967-96A1995F9DBA","type":{"custom":{"_0":{"direction":"TopRightQuarter","id":"58D920DA-7F37-477A-AB19-E0E2BD16A32F","keybind":[]}}}}
{"id":"63CA3EB7-7669-41A8-A144-374739757945","type":{"custom":{"_0":{"direction":"Cycle","id":"897E97B2-FA2D-40AD-A6A1-04ED90E84174","keybind":[],"name":"Top Right Third","cycle":[{"direction":"Custom","id":"2BF25516-6C00-40CD-9948-7E1D5F9B47B7","keybind":[],"name":"Top Right Third","unit":1,"positionMode":1,"sizeMode":0,"xPoint":66.667,"yPoint":0,"width":33.333,"height":50},{"direction":"Custom","id":"DC03B23A-0220-4CE1-B2CB-6445366CC925","keybind":[],"name":"Top Right Two Thirds","unit":1,"positionMode":1,"sizeMode":0,"xPoint":33.333,"yPoint":0,"width":66.667,"height":50}]}}}}
{"id":"057416F3-BD82-4F09-BCD4-45FE88C499FF","type":{"custom":{"_0":{"direction":"Cycle","id":"F6BBAC40-33AD-4A59-8734-50581606CBBD","keybind":[],"name":"Right","cycle":[{"direction":"RightHalf","id":"0647A981-FBD7-4379-A2D1-E75F7FEE5EB8","keybind":[]},{"direction":"RightThird","id":"EC2BE706-5407-4F2C-B6BF-4BA0BFEC23D3","keybind":[]},{"direction":"RightTwoThirds","id":"38483F91-506B-4599-8148-9A002805F3D4","keybind":[]}]}}}}
{"id":"DFCE3A14-C52D-4062-8293-BE372D11BF3E","type":{"custom":{"_0":{"direction":"Cycle","id":"18EA1873-13D5-4520-A23D-065BD858ED84","keybind":[],"name":"Bottom Right Third","cycle":[{"direction":"Custom","id":"8B59EA7B-9AB8-477D-A8B4-9C5077700076","keybind":[],"name":"Bottom Right Third","unit":1,"positionMode":1,"sizeMode":0,"xPoint":66.667,"yPoint":50,"width":33.333,"height":50},{"direction":"Custom","id":"907827C5-514B-4ADF-A8F6-AE0DA56F8014","keybind":[],"name":"Bottom Right Two Thirds","unit":1,"positionMode":1,"sizeMode":0,"xPoint":33.333,"yPoint":50,"width":66.667,"height":50}]}}}}
{"id":"185F2C1C-439E-4BB4-B945-07B6E8C8525A","type":{"custom":{"_0":{"direction":"BottomRightQuarter","id":"F1E15901-91CB-4201-B4D5-7E70317D9651","keybind":[]}}}}
{"id":"20CF160E-AC91-4A39-9090-82504EB4FB4E","type":{"custom":{"_0":{"direction":"Cycle","id":"4FBC1004-F615-46AA-8F1F-61C50707341A","keybind":[],"name":"Bottom Center","cycle":[{"direction":"Custom","id":"26E60ABA-C9F1-42DA-9923-93CBE0FADEC7","keybind":[],"name":"Bottom Center Third","unit":1,"positionMode":1,"sizeMode":0,"xPoint":33.333,"yPoint":50,"width":33.334,"height":50},{"direction":"Custom","id":"73C79597-2AB1-4C91-B36C-F899FD26E2E3","keybind":[],"name":"Bottom Center Half","unit":1,"positionMode":1,"sizeMode":0,"xPoint":25,"yPoint":50,"width":50,"height":50},{"direction":"Custom","id":"FBBB02EC-07A4-4835-A8B2-3BAD79377E37","keybind":[],"name":"Bottom Center Two Thirds","unit":1,"positionMode":1,"sizeMode":0,"xPoint":16.667,"yPoint":50,"width":66.666,"height":50}]}}}}
{"id":"695ADBEF-0E30-4D80-9A79-CC14EDCD70A6","type":{"custom":{"_0":{"direction":"BottomLeftQuarter","id":"6B61908E-4EB8-4409-A269-1E3890045AD5","keybind":[]}}}}
{"id":"CD0B25C0-5474-463E-91BA-BEBAFAD05ADA","type":{"custom":{"_0":{"direction":"Cycle","id":"508ECDA3-48F2-4DB5-BF4F-93B318F11DA3","keybind":[],"name":"Bottom Left Third","cycle":[{"direction":"Custom","id":"3A7A2579-9644-4BAE-80ED-2D446CBC9D3C","keybind":[],"name":"Bottom Left Third","unit":1,"positionMode":1,"sizeMode":0,"xPoint":0,"yPoint":50,"width":33.333,"height":50},{"direction":"Custom","id":"71524F54-66D2-49F6-A993-6690F656C0FD","keybind":[],"name":"Bottom Left Two Thirds","unit":1,"positionMode":1,"sizeMode":0,"xPoint":0,"yPoint":50,"width":66.667,"height":50}]}}}}
{"id":"333761A8-0E60-4ABC-8609-D6F64F74B0EB","type":{"custom":{"_0":{"direction":"Cycle","id":"5D746D42-5A94-4BC1-8D0F-7F92837A10DC","keybind":[],"name":"Left","cycle":[{"direction":"LeftHalf","id":"C39BAA02-D3DF-41A4-90EB-82706B2BA7B4","keybind":[]},{"direction":"LeftThird","id":"20E8A405-B53A-42E9-8097-E42063EB7DCD","keybind":[]},{"direction":"LeftTwoThirds","id":"3F12BF63-865F-4123-81F8-C7E28370CE81","keybind":[]}]}}}}
{"id":"A3E8763D-1D93-4167-A531-F47100240FAF","type":{"custom":{"_0":{"direction":"Cycle","id":"CEF6F179-01D7-40AE-A730-C4CE7FEF2E24","keybind":[],"name":"Top Left Third","cycle":[{"direction":"Custom","id":"07D2F960-F237-456B-B94F-1CDCA6F48F62","keybind":[],"name":"Top Left Third","unit":1,"positionMode":1,"sizeMode":0,"xPoint":0,"yPoint":0,"width":33.333,"height":50},{"direction":"Custom","id":"1E56470C-4DC9-4919-81AA-4B87D271A414","keybind":[],"name":"Top Left Two Thirds","unit":1,"positionMode":1,"sizeMode":0,"xPoint":0,"yPoint":0,"width":66.667,"height":50}]}}}}
{"id":"58DE5092-7F58-488B-B2C1-4FDEE47B21D2","type":{"custom":{"_0":{"direction":"TopLeftQuarter","id":"3FA63590-5173-4C4A-B2CF-F11CB91159DC","keybind":[]}}}}
{"id":"FE9B6B03-4D94-4017-B072-3AFCDE6129A2","type":{"custom":{"_0":{"direction":"Cycle","id":"DC374B27-EEE4-4A34-94E6-EC3E9FA4D5F9","keybind":[],"name":"Maximize + macOS Center","cycle":[{"direction":"Maximize","id":"8A9CED76-06DA-49F4-9F93-199314E57189","keybind":[]},{"direction":"MacOSCenter","id":"E59C5F58-AD32-4227-8667-A9F4FEC5C747","keybind":[]}]}}}}
RADIAL_EOF

cat > "$WORK/keybinds.txt" << "KEYBINDS_EOF"
{"direction":"HorizontalCenterHalf","id":"ABAF1D9F-9A63-436F-8BEE-1EE90DB3F9F7","keybind":[8]}
{"direction":"Maximize","id":"BE54CBEC-8F97-4A87-9946-D870C4BF5538","keybind":[49]}
{"direction":"Center","id":"AEB94CDC-A89D-46E0-BD39-3BE11C46E391","keybind":[36]}
{"cycle":[{"direction":"TopHalf","id":"4F797889-5C9D-49D9-91B1-F0E02A49B71C","keybind":[]},{"direction":"TopThird","id":"51655BD1-F554-4DB9-95B2-B50F89C2173F","keybind":[]},{"direction":"TopTwoThirds","id":"D928F289-DF34-40F6-A8A1-77EE0D19254E","keybind":[]}],"direction":"Cycle","id":"BD2C7A9B-176B-4C9A-A5E2-EAE7FF52D2D2","keybind":[126],"name":"Top Cycle"}
{"cycle":[{"direction":"BottomHalf","id":"E03A1D95-B7DB-4A20-8C6E-EE23D3B62AEB","keybind":[]},{"direction":"BottomThird","id":"A9877DF0-84CE-4E67-9258-08ED34741941","keybind":[]},{"direction":"BottomTwoThirds","id":"07EAC24E-B70D-4781-B0EE-FF7B14D24A75","keybind":[]}],"direction":"Cycle","id":"9FCB75B1-3F97-4AAB-B7B2-8E4885018C1C","keybind":[125],"name":"Bottom Cycle"}
{"cycle":[{"direction":"RightHalf","id":"C36AFD40-39A6-4DBE-B52D-20AEAA40897B","keybind":[]},{"direction":"RightThird","id":"2CD2AEF7-AA69-4A37-9108-47D54B8FE655","keybind":[]},{"direction":"RightTwoThirds","id":"1ED584C0-C43D-4D05-920D-B60330BC606F","keybind":[]}],"direction":"Cycle","id":"8714D8BF-B22D-4D97-94C8-4A53A39F6D6E","keybind":[124],"name":"Right Cycle"}
{"cycle":[{"direction":"LeftHalf","id":"FCDA3843-39D1-4AAE-92C2-C116134D8861","keybind":[]},{"direction":"LeftThird","id":"71419D40-5A5C-4076-903C-DD0F3D2AFB25","keybind":[]},{"direction":"LeftTwoThirds","id":"AD73F6D5-4E1C-477B-ACC4-3C19FFC4201A","keybind":[]}],"direction":"Cycle","id":"BCBD20F1-86D2-4899-BBA2-F303279FF96F","keybind":[123],"name":"Left Cycle"}
{"direction":"TopLeftQuarter","id":"895C44B2-22FA-474C-873C-0AFE2B041C4D","keybind":[126,123]}
{"direction":"TopRightQuarter","id":"6B22C764-4DCF-423D-BD00-0A46420F8350","keybind":[126,124]}
{"direction":"BottomRightQuarter","id":"72B01EEE-97BB-4C55-B7FB-106944F4C452","keybind":[124,125]}
{"direction":"BottomLeftQuarter","id":"A2E89344-27CB-4B51-BB80-4116CF968D9A","keybind":[125,123]}
{"direction":"Cycle","id":"C5FB769E-0411-47A0-9E96-E178B9E4274F","keybind":[123,124],"name":"Center Cycle","cycle":[{"direction":"HorizontalCenterThird","id":"8FF05B3C-7639-4C8D-8417-478D658A4397","keybind":[]},{"direction":"HorizontalCenterHalf","id":"8D16EF32-B700-448B-AF3E-D88BD64D1FAF","keybind":[]}]}
KEYBINDS_EOF

# --- 1. Save the current preferences -------------------------------------------

if defaults export "$DOMAIN" "$BACKUP" 2>/dev/null; then
  echo "    backup: $BACKUP"
else
  echo "    no existing preferences; nothing to back up"
  BACKUP=""
fi

# --- 2. Quit Loop ---------------------------------------------------------------

if pgrep -f "Loop.app/Contents/MacOS/Loop" > /dev/null; then
  osascript -e "tell application \"Loop\" to quit" 2>/dev/null || true
  for _ in $(seq 1 20); do
    pgrep -f "Loop.app/Contents/MacOS/Loop" > /dev/null || break
    sleep 0.5
  done
  if pgrep -f "Loop.app/Contents/MacOS/Loop" > /dev/null; then
    echo "!!! Loop did not quit. Quit it yourself, then run this script again." >&2
    exit 1
  fi
  echo "    Loop quit"
fi

# --- 3. Build the new preferences ------------------------------------------------

CUR="$WORK/current.plist"
if ! defaults export "$DOMAIN" "$CUR" 2>/dev/null; then
  printf "{}" > "$WORK/empty.json"
  plutil -convert xml1 "$WORK/empty.json" -o "$CUR"
fi

write_array() {  # $1 = data file, $2 = preference key
  local xml="$WORK/$2.xml"
  {
    echo "<array>"
    while IFS= read -r line; do
      [ -n "$line" ] && printf "<string>%s</string>\n" "$line"
    done < "$1"
    echo "</array>"
  } > "$xml"
  plutil -replace "$2" -xml "$(cat "$xml")" "$CUR"
}

write_array "$WORK/radial.txt" radialMenuActions
write_array "$WORK/keybinds.txt" keybinds
plutil -replace enableRadialMenuCustomization -bool true "$CUR"
plutil -lint "$CUR" > /dev/null

# --- 4. Apply ---------------------------------------------------------------------

defaults import "$DOMAIN" "$CUR"

CHECK="$WORK/check.plist"
defaults export "$DOMAIN" "$CHECK"
plutil -extract radialMenuActions json -o "$WORK/rm.json" "$CHECK"
plutil -extract keybinds json -o "$WORK/kb.json" "$CHECK"
echo "    applied: $(grep -c "" "$WORK/radial.txt") radial menu segments, $(grep -c "" "$WORK/keybinds.txt") keybinds"

# --- 5. Start Loop again -----------------------------------------------------------

if [ -d "$APP" ]; then
  open -a "$APP"
  echo "    Loop started"
else
  echo "    Loop is not in /Applications; start it yourself"
fi

echo "==> Done."
if [ -n "$BACKUP" ]; then
  echo "    To undo: quit Loop, then run:"
  echo "      defaults import $DOMAIN \"$BACKUP\""
fi
echo "    Note: the radial menu highlight fix is a source change. It is not in this file."
