function ms-manageParseVersion()
{
    ARCHIVE=$1
    VERSION=$(sed 's/.*\([0-9]\.\([0-9]\|[0-9][0-9]\)\.[0-9]\.[0-9]\).*/\1/' <<< $ARCHIVE)
    echo $VERSION
}

function ms-manageExtractArchive()
{
    FILE=$1
    case $FILE in
        $TARGZ)
                echo "Its here tar gz";
                tar -xf $FILE;
        ;;
        $ZIP)
                echo "Its here zip";
                unzip -q $FILE;
        ;;
        $TARBZ2)
                echo "Its here tar bz2";
                bzip2 -q -d -k $FILE;
        ;;
        *)
        exit 1
    esac
}
function ms-manageRemoveDummyChangesCE()
{
    cd magento;
    PARM=`grep -i 'self::EDITION_COMMUNITY' app/Mage.php`;
    echo $PARM;
    if [ -z "$PARM" ]; then
        echo "Magento comunity edition not detected";
        exit 0;
    fi
    find . -name '*.css*' -print0 -o -name '*.html*' -print0 -o -name '*.js*' -print0 -o -name '*.php*' -print0 -o -name '*.phtml*' -print0 -o -name '*.xml*' -print0 | xargs -0 sed -i 's/\((c) 200.-20.. X.commerce,\)\|\((c) 201. Magento\)/(c) 2012 Magento/g';
    find . -name '*.css*' -print0 -o -name '*.html*' -print0 -o -name '*.js*' -print0 -o -name '*.php*' -print0 -o -name '*.phtml*' -print0 -o -name '*.xml*' -print0 | xargs -0 sed -i 's/www.magento.com/www.magentocommerce.com/g';
    find . -name '*.css*' -print0 -o -name '*.html*' -print0 -o -name '*.js*' -print0 -o -name '*.php*' -print0 -o -name '*.phtml*' -print0 -o -name '*.xml*' -print0 | xargs -0 sed -i 's/license@magento.com/license@magentocommerce.com/g';
    cd ../;
}

function ms-manageRemoveDummyChangesEE()
{
    cd magento;
    PARM=`grep -i 'self::EDITION_ENTERPRISE' app/Mage.php`;
    if [  -z "$PARM" ]; then
        echo "Magento enterprise edition not detected";
        exit 0;
    fi
    find . -name '*.css*' -print0 -o -name '*.html*' -print0 -o -name '*.js*' -print0 -o -name '*.php*' -print0 -o -name '*.phtml*' -print0 -o -name '*.xml*' -print0 | xargs -0 sed -i -e '/\/\*\*/,/*\//d; /^\/\//d;';
    cd ../;
}
