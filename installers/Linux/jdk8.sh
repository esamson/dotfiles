set -e

installDir="$HOME/.local/opt/jdk-8u72"

if [ -f "$installDir/bin/javac" ]; then
    echo "jdk8 already installed"
    exit
fi

cacheDir="$HOME/.local/cache"

mkdir -p $installDir
mkdir -p $cacheDir

jdkUrl="http://download.oracle.com/otn-pub/java/jdk/8u72-b15/jdk-8u72-linux-x64.tar.gz"
jdkSha256="46e7f96271043009995f39f04a9e711cdc0cc5b6a5b67910451678a3d250ec98"
jdkFile="$cacheDir/${jdkUrl##*/}"

if [ ! -r "$jdkFile" ]; then
    echo "downloading $jdkFile from $jdkUrl"
    curl -o $jdkFile --location --header "Cookie: oraclelicense=accept-securebackup-cookie" $jdkUrl
fi

jdkCheck=($(sha256sum "$jdkFile"))
if [ "$jdkCheck" != "$jdkSha256" ]; then
    echo "$jdkFile is corrupt. expected $jdkSha256 got $jdkCheck"
    exit 1
fi

tar -x -f "$jdkFile" -C "$installDir" --strip-components=1

apiDocsUrl="http://download.oracle.com/otn-pub/java/jdk/8u72-b15/jdk-8u72-docs-all.zip"
apiDocsSha256="42c9dc79dc222aa72d198113d5de0bb32b8636fa1ecc10af65e759b2bd4bec3b"
apiDocsFile="$cacheDir/${apiDocsUrl##*/}"

if [ ! -r "$apiDocsFile" ]; then
    echo "downloading $apiDocsFile from $apiDocsUrl"
    curl -o $apiDocsFile --location --header "Cookie: oraclelicense=accept-securebackup-cookie" $apiDocsUrl
fi

apiDocsCheck=($(sha256sum "$apiDocsFile"))
if [ "$apiDocsCheck" != "$apiDocsSha256" ]; then
    echo "$apiDocsFile is corrupt. expected $apiDocsSha256 got $apiDocsCheck"
    exit 1
fi

unzip "$apiDocsFile" -d "$installDir"

javafxDocsUrl="http://download.oracle.com/otn-pub/java/javafx/8.0.72-b15/javafx-8u72-apidocs.zip"
javafxDocsSha256="71b17e673523543e35b1cb3fec508d4a8d82887c5aea7aa58e2d2f2fbfdbe3de"

javafxDocsFile="$cacheDir/${javafxDocsUrl##*/}"

if [ ! -r "$javafxDocsFile" ]; then
    echo "downloading $javafxDocsFile from $javafxDocsUrl"
    curl -o $javafxDocsFile --location --header "Cookie: oraclelicense=accept-securebackup-cookie" $javafxDocsUrl
fi

javafxDocsCheck=($(sha256sum "$javafxDocsFile"))
if [ "$javafxDocsCheck" != "$javafxDocsSha256" ]; then
    echo "$javafxDocsFile is corrupt. expected $javafxDocsSha256 got $javafxDocsCheck"
    exit 1
fi

javafxDocsDir="$installDir/docs/javafx"
mkdir -p "$javafxDocsDir"
unzip "$javafxDocsFile" -d "$javafxDocsDir"
