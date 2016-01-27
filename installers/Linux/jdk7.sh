set -e

installDir="$HOME/.local/opt/jdk-7u80"

if [ -f "$installDir/bin/javac" ]; then
    echo "jdk7 already installed"
    exit
fi

cacheDir="$HOME/.local/cache"

mkdir -p $installDir
mkdir -p $cacheDir

jdkUrl="http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-linux-x64.tar.gz"
jdkSha256="bad9a731639655118740bee119139c1ed019737ec802a630dd7ad7aab4309623"
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

apiDocsUrl="http://download.oracle.com/otn-pub/java/jdk/7u80-b15/jdk-7u80-docs-all.zip"
apiDocsSha256="0494bd49bc9cb3cbe3203120ae8b2c8e0aeb1579cb15c0fbd3cd780d19aa200a"
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
