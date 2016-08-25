########################################### VARIABLES DECLARATION ######################################################

#function declareVariables() {                               # Declares necessary variables
#    declare -a -g STATE_MACHINE_BOLD=( );
#    declare -a -g STATE_MACHINE_ITALIC=( );
#    declare -a -g STATE_MACHINE_UNDERLINE=( );
#    declare -a -g STATE_MACHINE_COLOR=( );
#    declare -a -g STATE_MACHINE_BACKGROUND=( );
#    declare -a -g STATE_MACHINE_INDENT=( );
##    declare STATE_MACHINE_LIST=0;
#
#}

######################################################### TESTS ########################################################

function isBold() {
    ARG_NUMBER="${#STATE_MACHINE_BOLD[@]}"
    if [[ ${ARG_NUMBER} == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function isItalic() {
    ARG_NUMBER="${#STATE_MACHINE_ITALIC[@]}"
    if [[ ${ARG_NUMBER} == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}
function isUnderline() {
    ARG_NUMBER=`echo ${#STATE_MACHINE_UNDERLINE[@]}`
    if [[ ${ARG_NUMBER} == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function isColor() {
    ARG_NUMBER=`echo ${#STATE_MACHINE_COLOR[@]}`
    if [[ ${ARG_NUMBER} == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function isBackground() {
    ARG_NUMBER=`echo ${#STATE_MACHINE_BACKGROUND[@]}`
    if [[ ${ARG_NUMBER} == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function isIndent() {
    ARG_NUMBER=`echo ${#STATE_MACHINE_INDENT[@]}`
    if [[ ${ARG_NUMBER} == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

function isList() {
    ARG_NUMBER=`echo ${#STATE_MACHINE_LIST[@]}`
    if [[ ${ARG_NUMBER} == 0 ]]; then
        echo 1
    else
        echo 0
    fi
}

################################################## PRINTING ############################################################

function fmtPrint.content() {                                   # This function prints the given string of text
    local TEXT="${1}";                                          # formatted according to attributes values
    local PREFIX="\e[";
    local SUFFIX="\e[0m";
    local IS_BOLD=`isBold`;
    local IS_ITALIC=`isItalic`;
    local IS_UNDERLINE=`isUnderline`;
    local IS_COLOR=`isColor`;
    local IS_BACKGROUND=`isBackground`;
    local IS_INDENT=`isIndent`;


    if [[ "${IS_BOLD}" == 0 ]]; then
        PREFIX="${PREFIX}${PRE_BOLD}"
    fi;

    if [[ "${IS_ITALIC}" == 0 ]]; then
        PREFIX="${PREFIX};${PRE_ITALIC}"
    fi

    if [[ "${IS_UNDERLINE}" == 0 ]]; then
        PREFIX="${PREFIX};${PRE_UNDERLINE}"
    fi

    if [[ "${IS_COLOR}" == 0 ]]; then
        local COLOR=`echo ${STATE_MACHINE_COLOR[-1]}`
        local PRE_COLOR=PRE_COLOR_$COLOR

        PREFIX="${PREFIX};${!PRE_COLOR}"
    fi

    if [[ "${IS_BACKGROUND}" == 0 ]]; then
        local BACKGROUND=`echo ${STATE_MACHINE_BACKGROUND[-1]}`
        local PRE_BACKGROUND=PRE_BACKGROUND_$BACKGROUND

        PREFIX="${PREFIX};${!PRE_BACKGROUND}"
    fi

    if [[ "${IS_INDENT}" == 0 ]]; then
        local INDENTION=`echo ${STATE_MACHINE_INDENT[-1]}`
        local PRE_INDENT=PRE_INDENT_$INDENTION

        PREFIX="${!PRE_INDENT}${PREFIX}"
    fi

    local PRINT_TEXT="${PREFIX}m${TEXT}${SUFFIX}";
    echo -e "${PRINT_TEXT}";
}

function fmtPrint.blank() {                                     # Prints an empty line
    echo -e ""
}

function fmtPrint.uppercase() {                                 # Prints a string transformed into uppercase
#    CONTENT=$(
#        for i in "${*}"; do
#            echo "${i^^}"
#        done
#    );
#
#    echo "${CONTENT^^}"
    echo "${*^^}";
}

function fmtPrint.lowercase() {                                 # Prints a string transformed into lowercase
    echo "${1,,}";
}

function fmtPrint.capitalize() {                                # Prints a string transformed into capitalized
    echo "${1^}";

}

function fmtPrint.lineA() {                                     # Prints first type of section line
    local start=$'\e(0' end=$'\e(B' line='qqqqqqqqqqqqqqqq';
    local cols=${COLUMNS:-$(tput cols)};

    while ((${#line} < cols)); do line+="$line"; done;
    printf '%s%s%s\n' "$start" "${line:0:cols}" "$end";
}

function fmtPrint.lineB() {                                     # Prints second type of section line
    local start=$'\e(0' end=$'\e(B' line='================';
    local cols=${COLUMNS:-$(tput cols)};

    while ((${#line} < cols)); do line+="$line"; done;
    printf '%s%s%s\n' "$start" "${line:0:cols}" "$end";
}

function fmtPrint.lineC() {                                     # Prints third type of section line
    local start=$'\e(0' end=$'\e(B' line='----------------';
    local cols=${COLUMNS:-$(tput cols)};

    while ((${#line} < cols)); do line+="$line"; done;
    printf '%s%s%s\n' "$start" "${line:0:cols}" "$end";
}

function fmtPrint.lineD() {                                     # Prints fourth type of section line
    local start=$'\e(0' end=$'\e(B' line='-  -  -  -  -  ';
    local cols=${COLUMNS:-$(tput cols)};

    while ((${#line} < cols)); do line+="$line"; done;
    printf '%s%s%s\n' "$start" "${line:0:cols}" "$end";
}

######################################################### RESET ########################################################

function fmtResetFormatting() {                                 # Resets formatting for the given attribute
   stateMachine.drop ${1};
}

################################################## FONT FORMATTING #####################################################


function fmtUnderline.open() {                              # Enables Underlined formatting
    stateMachine.push UNDERLINE UNDERLINE
}
function fmtUnderline.close() {                             # Disables Underlined formatting
    stateMachine.pop UNDERLINE
}


function fmtBold.open() {                                   # Enables Bold formatting
    stateMachine.push BOLD BOLD
}
function fmtBold.close() {                                  # Disables Bold formatting
     stateMachine.pop BOLD
}


function fmtItalic.open() {                                 # Enables Italic formatting
    stateMachine.push ITALIC ITALIC
}
function fmtItalic.close() {                                # Disables Italic formatting
    stateMachine.pop ITALIC
}

######################################################## COLORS ########################################################

function fmtColorReversed.open() {                          # Enables reversed text formatting
    stateMachine.push COLOR REVERSED
}
function fmtColorBlack.open() {                             # Enables black text formatting
    stateMachine.push COLOR BLACK
}
function fmtColorRed.open() {                               # Enables red text formatting
    stateMachine.push COLOR RED
}
function fmtColorGray.open() {                              # Enables grey text formatting
    stateMachine.push COLOR GRAY
}
function fmtColorYellow.open() {                            # Enables yellow text formatting
    stateMachine.push COLOR YELLOW
}
function fmtColorGreen.open() {                             # Enables green text formatting
    stateMachine.push COLOR GREEN
}
function fmtColorBlue.open() {                              # Enables blue text formatting
    stateMachine.push COLOR BLUE
}
function fmtColorPurple.open() {                            # Enables purple text formatting
    stateMachine.push COLOR PURPLE
}
function fmtColorWhite.open() {                             # Enables white text formatting
    stateMachine.push COLOR WHITE
}
function fmtColor.close() {                                 # Restores previous text color
    stateMachine.pop COLOR
}

###################################################### BACKGROUND ######################################################

function fmtBackgroundRed.open() {                          # Enables red background color
    stateMachine.push BACKGROUND RED
}
function fmtBackgroundGreen.open() {                        # Enables green background color
    stateMachine.push BACKGROUND GREEN
}
function fmtBackgroundYellow.open() {                       # Enables yellow background color
    stateMachine.push BACKGROUND YELLOW
}
function fmtBackgroundBlue.open() {                         # Enables blue background color
        stateMachine.push BACKGROUND BLUE
}
function fmtBackgroundPurple.open() {                       # Enables purple background color
    stateMachine.push BACKGROUND PURPLE
}
function fmtBackgroundWhite.open() {                        # Enables white background color
    stateMachine.push BACKGROUND WHITE
}
function fmtBackgroundDefault.open() {                      # Enables default background color
    stateMachine.push BACKGROUND DEFAULT
}
function fmtBackground.close() {                            # Restores previous background color
    stateMachine.pop BACKGROUND
}

################################################### TEXT ALIGNMENT #####################################################

function fmtIndent.open() {                                    # Create the next level of indention
    VAR=`expr ${#STATE_MACHINE_INDENT[@]} + 1`
    stateMachine.push INDENT ${VAR}
}
function fmtIndent.close() {                                   # Restores previous level of indention
    stateMachine.pop INDENT
}
function fmtAlign.center() {
    local columns="$(tput cols)";
    local string="${1}";

    printf "%*s\n" $(((${columns} + ${#string}) / 2)) "${string}";
}

function fmtAlign.right() {
    local columns="$(tput cols)";
    local string=`echo ${1}`;

    printf "%*s\n" "${columns}" "${string}";
}

################################################## Predefined styles ###################################################

function fmtSectionHeader() {
    CONTENT=$(
        for i in "${*}"; do
            echo "${i}"
        done
    );

#    fmtColorGreen.open && fmtBold.open && fmtPrint.content `fmtPrint.uppercase "${@}"`
    fmtColorGreen.open && fmtBold.open && fmtPrint.content `fmtPrint.uppercase "${CONTENT}"`
}

#
#function fmtInfoBox() {
#    local heading="${1}";
#    local content="${2}";
#    local columns="$(tput cols)";
#    local rows="$(tput lines)";
#    local boxWidth=$((${columns} / 2));
#    local boxHeight=$((${rows} / 2));
#
#    whiptail --title "${heading}" --msgbox "${content}" "${boxHeight}" "${boxWidth}";
#}
#
#function fmtH1.info() {
#    local VAR=`echo "${1^^}"`
#    local CONTENT=`fmtColorGreen.open && fmtBold.open && fmtPrint "${VAR}"`;
#
#    fmtAlign.center "$CONTENT";
#    fmtSectionLine;
#}
#
#function fmtH1.alert() {
#    fmtAlign.center `fmtColorRed.open && fmtBold.open && fmtPrint ${1^^}`;
#    fmtSectionLine;
#}
#
#function fmtH1.warning() {
#    fmtAlign.center `fmtColorYellow.open && fmtBold.open && fmtPrint "${1^^}"`;
#    fmtSectionLine;
#}
#
#function fmtH2() {
#    fmtColorReversed.open && fmtBold.open;
#    fmtPrint "${1^^}";
#    fmtSectionLine;
#}
#
#function fmtH3() {
#    fmtColorGray.open && fmtBackgroundWhite.open && fmtPrint "${1}";
#}
#
#function fmtH1() {
#    local string="${1^^}";
#
#    fmtBold.open;
#    fmtColorGreen;
#    fmtSectionLine;
#    fmtAlign.center "${string}";
#    fmtSectionLine;
#    fmtDefault;
#
#}
#
#function fmtH2() {
#    local string="${1}";
#
#    fmtBold.open;
#    fmtItalic.open;
#    fmtColorRed;
#    fmtSectionLine;
#    fmtAlign.center "${string}";
#    fmtSectionLine;
#    fmtDefault;
#}
#
#function fmtH3() {
#    local string="${1^^}";
#
#    fmtBold.open;
#    fmtSectionLine;
#    echo -e "${string}";
#    fmtSectionLine;
#    fmtDefault;
#}
#
######################################################### LOGOS ########################################################

function logo() {
    local cols="$(tput cols)";

    if [ "${cols}" -le 202 ];
    then
        fmtPrint.lineA;
        fmtAlign.center "|                                                          |";
        fmtAlign.center "|       _____                 __         _  __             |";
        fmtAlign.center "|      / ___/____ ___  ___ _ / /_ __ __ (_)/ /_ __ __      |";
        fmtAlign.center "|     / /__ / __// -_)/ _  // __// // // // __// // /      |";
        fmtAlign.center "|     \___//_/   \__/ \_,_/ \__/ \_,_//_/ \__/ \_, /       |";
        fmtAlign.center "|                                             /___/        |";
        fmtAlign.center "|                                                          |";
        fmtAlign.center "|                  ____ __                   _     __      |";
        fmtAlign.center "|    ___   ___    / __// /_ ___  ____ ___   (_)___/ /___   |";
        fmtAlign.center "|   / _ \ / _ \  _\ \ / __// -_)/ __// _ \ / // _  /(_-<   |";
        fmtAlign.center "|   \___//_//_/ /___/ \__/ \__//_/   \___//_/ \_,_//___/   |";
        fmtAlign.center "|                                                          |";
        fmtPrint.lineA;
    else
        fmtAlign.center "                                                                                                                              MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                             "
        fmtAlign.center "                                                                                                                           MMMMMMMMMMMMMMMMMMMMMMMMM   MMMMMMMMMMMMMMMMMMMMMMMMM                          "
        fmtAlign.center "                                                                                                                        MMMMMMMMMMMMMMMMMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMMMMMMMMMM                       "
        fmtAlign.center "                                                                                                                       MMMMMMMMMMMMMMMMMMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMMMMMMMMMMM                      "
        fmtAlign.center "                                                                                                                      MMMMMMMMMMMMMMMMMMMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMMMMMMMMMMMM                     "
        fmtAlign.center "                                                                                                                     MMMMMMMMMMMMMMM     MMMMMMMMMM     MMMMMMMMMM     MMMMMMMMMMMMMMM                    "
        fmtAlign.center "                                                                                                                    MMMMMMMMMMMMMMMM      MMMMMMMMM     MMMMMMMMM      MMMMMMMMMMMMMMMM                   "
        fmtAlign.center "                                                                                                                   MMMMMMMMMMMMMMMMMM      MMMMMMMM     MMMMMMMM      MMMMMMMMMMMMMMMMMM                  "
        fmtAlign.center "                                                                                                                   MMMMMMMMMMMMMMMMMMM      MMMMMMM     MMMMMMM      MMMMMMMMMMMMMMMMMMM                  "
        fmtAlign.center "                                                                                                                  MMMMMMMMMMMMMMMMMMMMM      MMMMMMM   MMMMMMM      MMMMMMMMMMMMMMMMMMMMM                 "
        fmtAlign.center "                                                                                                                  MMMMMMMMMMMMMMMMMMMMMMM     MMMMMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMMMMMM                 "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMMMMMMMMMMMMMMM     MMMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMMMMMMMM                "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM      MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM          MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMMM              MMMM            MMMM              MMMMMMMMMMMM                "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMM               MMMM            MMMM               MMMMMMMMMMM                "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM            MMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM      MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                "
        fmtAlign.center "                                                                                                                 MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM                "
        fmtAlign.center "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMNMMMMMMMMMMMMMMMMMMMMM"
        fmtAlign.center "MMMMMMM           MMMMMMMMMM                  MMMMMMMMM                MMMMMMMMMMMMMMM  MMMMMMMM                   MMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMM                   MMMMM    MMMMMMMMMMM    M"
        fmtAlign.center "MMMMM               MMMMMMMM    MMMMMMMMM       MMMMMMM                MMMMMMMMMMMMMM    MMNMMMM                   MMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMM                   MMMMMM    MMMMMMMMM    MM"
        fmtAlign.center "MMM     MMMMMMMMM     MMMMMM    MMMMMMMMMMM      MMMMMM    MMMMMMMMMMMMMMMMMMMMMMMMM      MMMMMMMMMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMM    MMMMMMM    MMM"
        fmtAlign.center "MM    MMMMMMMMMMMMM    MMMMM    MMMMMMMMMMMM      MMMMM    MMMMMMMMMMMMMMMMMMMMMMMM        MMMMMMMMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMM    MMMMM    MMMM"
        fmtAlign.center "M    MMMMMMMMMMMMMMMMMMMMMMM    MMMMMMMMMMMM     MMMMMM    MMMMMMMMMMMMMMMMMMMMMMM    MM    MMMMMMMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMM    MMM    MMMMM"
        fmtAlign.center "M    MMMMMMMMMMMMMMMMMMMMMMM    MMMMMMMMMMM     MMMMMMM                MMMMMMMMMM    MMMM    MMMMMMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMM    M    MMMMMM"
        fmtAlign.center "M    MMMMMMMMMMMMMMMMMMMMMMM    MMMMMMMMM      MMMMMMMM                MMMMMMMMM    MMMMMM    MMMMMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMMM       MMMMMMM"
        fmtAlign.center "M    MMMMMMMMMMMMMMMMMMMMMMM                MMMMMMMMMMM    MMMMMMMMMMMMNMMMMMMM    MMMMMMMM    MMMMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMM     MMMMMMMM"
        fmtAlign.center "M     NMMMMMMMMMMMMMMMMMMMMM    MMMMM     MMMMMMMMMMMMM    MMMMMMMMMMMMMMMMMMM                  MMMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMM     MMMMMMMM"
        fmtAlign.center "MM      MMMMMMMMMMM    MMMMM    MMMMMM     MMMMMMMMMMMM    MMMMMMMMMMMMMMMMMM    MMMMMMMMMMMM    MMMMMM     MMMMMMMMMMMM     MMMMMMMMMMMM     MMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMM     MMMMMMMM"
        fmtAlign.center "MMM       MNMMMMM     MMMMMM    MMMMMMMM     MMMMMMMMMM    MMMMMMMMMMMMMMMMM    MMMMMMMMMMMMMM    MMMMM     MMMMMMMMMMMMM     MMMMMMMMMM     MMMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMM     MMMMMMMM"
        fmtAlign.center "MMMMMM               MMMMMMM    MMMMMMMMM     MMMMMMMMM                MMMM    MMMMMMMMMMMMMMMM    MMMM     MMMMMMMMMMMMMM                  MMMMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMM     MMMMMMMM"
        fmtAlign.center "MMMMMMMM          NMMMMMMMMM    MMMMMMMMMM     MMMMMMMM                MMM    MMMMMMMMMMMMMMMMMM    MMM     MMMMMMMMMMMMMMMMM           MMMMMMMMMMM      MMMMMMMMMMMM     MMMMMMMMMMMMMMMMMMM     MMMMMMMM"
        fmtAlign.center "MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM"
    fi
}