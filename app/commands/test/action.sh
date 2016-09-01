
function runAction() {
    #config.sh loaded automatically
    #echo "TEST MODULE"
    #echo ""

    #loading config file dev.sh in order
    #core/config/common/dev.sh
    #app/config/common/dev.sh
    #core/config/env/local/dev.sh
    #app/config/env/local/dev.sh
    #core/config/role/developer/dev.sh
    #app/config/role/developer/dev.sh
    configLoad "dev.sh";
    configLoad "output-formatter-variables.sh";
    #Call function from module app/modules/example.sh
    fmtPrint.blank;
    fmtAlign.center $( fmtUnderline.open && fmtColorReversed.open && fmtPrint.content "LIST OF AVAILABLE FUNCTIONS:" );
    fmtPrint.blank;
    # 1 paragraph
    fmtBold.open && fmtIndent.open && fmtPrint.content "1. BASIC PRINTING";
    fmtPrint.blank && fmtPrint.blank;
        # 1 printing function
    fmtIndent.open && fmtPrint.content 'fmtPrint.content';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function analyzes the output formatter variables";
    fmtPrint.content "and prints the formatted string";
    fmtPrint.blank && fmtPrint.blank;
        # 2 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.blank';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function prints an empty lane."
    fmtPrint.blank && fmtPrint.blank;
        # 3 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.capitalize';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function transforms given string into capitalized."
    fmtPrint.blank && fmtPrint.blank;
        # 4 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.uppercase';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function transforms given string into uppercase."
    fmtPrint.blank && fmtPrint.blank;
        # 5 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.lowercase';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function transforms given string into lowercase."
    fmtPrint.blank && fmtPrint.blank;
        # 6 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.lineA';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function prints first type of a section line"
    fmtPrint.blank && fmtPrint.blank;
        # 7 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.lineB';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function prints second type of a section line"
    fmtPrint.blank && fmtPrint.blank;
        # 8 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.lineC';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function prints second type of a section line"
    fmtPrint.blank && fmtPrint.blank;
        # 9 printing function
    fmtBold.open && fmtPrint.content 'fmtPrint.lineD';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function prints second type of a section line"
    fmtPrint.blank && fmtPrint.blank && fmtPrint.blank && fmtPrint.blank;
    fmtResetFormatting;
    # 2 paragraph
    fmtBold.open && fmtIndent.open && fmtPrint.content "2. CHANGING THE FORMAT";
    fmtPrint.blank && fmtPrint.blank;
        # Bold
    fmtIndent.open && fmtPrint.content 'fmtBold.open';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function analyzes the output formatter variables";
    fmtPrint.content "and prints the formatted string";
    fmtPrint.blank && fmtPrint.blank;

    fmtBold.open && fmtPrint.content 'fmtBold.close';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function prints an empty lane."
    fmtPrint.blank && fmtPrint.blank;
        # Underline
    fmtBold.open && fmtPrint.content 'fmtUnderline.open';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function analyzes the output formatter variables";
    fmtPrint.content "and prints the formatted string";
    fmtPrint.blank && fmtPrint.blank;

    fmtBold.open && fmtPrint.content 'fmtUnderline.close';
    fmtPrint.blank;
    fmtBold.close && fmtPrint.content "This function prints an empty lane."
    fmtPrint.blank && fmtPrint.blank;

    fmtPrint.logo;


    #Call function 'gitState' from module app/modules/git.sh
    #'gitState' from core/modules/git.sh was overridden
}