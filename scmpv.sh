#!/bin/bash

# github.com/deimfy/scmpv
# license: MIT
# dependencies: mpv, youtube-dl, curl

if [ $ZSH_VERSION ]; then
    setopt sh_word_split
fi

search-tracks() {
    curl -sL "https://soundcloud.com/search/sounds?q=$@" -o $HOME/.cache/scmpv/0
    result_html=$(<$HOME/.cache/scmpv/0)
    result_array=$(echo $result_html | tr -d '\n' | sed -e 's% %SCMPVSPACELOL%g' -e 's%[^ ]*</a></li>SCMPVSPACELOL</ul>SCMPVSPACELOL<ul>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/%%g' -e 's%</a></h2></li>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/% %g' -e 's%</a>[^ ]*%%g' -e 's%<!DOCTYPESCMPVSPACELOLhtml>[^ ]*%%g')
    if [[ $result_array == "" ]]; then
            echo -e "$(tput setaf 9)Could not find track: $@$(tput sgr0)"
            rm -rf $HOME/.cache/scmpv
            exit 1
    fi
    num=0
    for x in $result_array ; do
        result=$(echo $x | sed 's%">[^ ]*%%g')
        
        export result$num=$result
        curl -sL "https://soundcloud.com/$result" -o $HOME/.cache/scmpv/1
        result_html1=$(<$HOME/.cache/scmpv/1)
        result_array1=$(echo $result_html1 | tr -d '\n' | sed -e 's% %SCMPVSPACELOL%g' -e 's%[^ ]*<h1SCMPVSPACELOLitemprop="name"><aSCMPVSPACELOLitemprop="url"SCMPVSPACELOLhref="/%%g' -e 's%</a>SCMPVSPACELOLbySCMPVSPACELOL<aSCMPVSPACELOLhref="/% %g' -e 's%</a></h1>SCMPVSPACELOLpublishedSCMPVSPACELOLonSCMPVSPACELOL<timeSCMPVSPACELOLpubdate>% %g' -e 's%-[0-9][0-9]-[^ ]*duration"SCMPVSPACELOLcontent="% %g' -e 's%"SCMPVSPACELOL/[^ ]*%%g')
        num_=0
        for y in $result_array1 ; do
            export echo$num_="$(echo -e "$y" | sed -e 's%[^ ]*">%%g' -e 's%SCMPVSPACELOL% %g')"
            if [[ $y =~ ^PT[0-9][0-9]H[0-9][0-9]M[0-9][0-9]S ]] ; then
                export echo$num_=$(echo $y | sed -e 's%PT%%g' -e 's%[HM]%:%g' -e 's%S%%g')
            fi
            num_=$((num_+1))
        done
        num=$((num+1))
        echo -e "$(tput setaf 7) $num) $echo1 - \"$echo0\" ($echo3|$echo2)$(tput sgr0)"
        
    done
    
    ask-selection
    
}

search-people() {
    curl -sL "https://soundcloud.com/search/people?q=$@" -o $HOME/.cache/scmpv/0
    result_html=$(<$HOME/.cache/scmpv/0)
    result_array=$(echo $result_html | tr -d '\n' | sed -e 's% %SCMPVSPACELOL%g' -e 's%[^ ]*</a></li>SCMPVSPACELOL</ul>SCMPVSPACELOL<ul>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/%%g' -e 's%</a></h2></li>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/% %g' -e 's%</a>[^ ]*%%g' -e 's%<!DOCTYPESCMPVSPACELOLhtml>[^ ]*%%g')
    if [[ $result_array == "" ]]; then
            echo -e "$(tput setaf 9)Could not find artist: $@$(tput sgr0)"
            rm -rf $HOME/.cache/scmpv
            exit 1
    fi
    num=0
    for x in $result_array ; do
        result=$(echo $x | sed 's%">% %g')
        export result$num="$(echo -e $result | sed 's% [^ ]*%%g')/tracks"
        num_=0
        for y in $result ; do
            export echo$num_="$(echo -e "$y" | sed -e 's%[^ ]*">%%g' -e 's%SCMPVSPACELOL% %g')"
            num_=$((num_+1))
        done
        num=$((num+1))
        echo -e "$(tput setaf 7) $num) $echo1 ($echo0)$(tput sgr0)"
    done

    ask-selection
}

search-albums() {
    # apparently searching album via 
    # curl https://soundcloud.com/search/albums?q=STRING
    # doesn't return links for the album
    # so i use hacky workaraound using
    # https://soundcloud.com/search?q=STRING
    # and look for links containing "/sets/"
    # it may be buggy or even not showing result at all
    
    curl -sL "https://soundcloud.com/search?q=$@+album" -o $HOME/.cache/scmpv/0
    result_html=$(<$HOME/.cache/scmpv/0)
    result_array=$(echo $result_html | tr -d '\n' | sed -e 's% %SCMPVSPACELOL%g' -e 's%[^ ]*</a></li>SCMPVSPACELOL</ul>SCMPVSPACELOL<ul>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/%%g' -e 's%</a></h2></li>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/% %g' -e 's%</a>[^ ]*%%g' -e 's%<!DOCTYPESCMPVSPACELOLhtml>[^ ]*%%g')
    if [[ $result_array == "" ]]; then
        echo -e "$(tput setaf 9)Could not find album: $@$(tput sgr0)"
        rm -rf $HOME/.cache/scmpv
        exit 1
    fi
    num=0
    for x in $result_array ; do
        result=$(echo $x | sed 's%">[^ ]*%%g')
        if [[ ! $result =~ ^[^\ ]*/sets/[^\ ]* ]] ; then
            continue
        fi
        export result$num=$result
        curl -sL "https://soundcloud.com/$result" -o $HOME/.cache/scmpv/1
        result_html1=$(<$HOME/.cache/scmpv/1)
        result_array1=$(echo $result_html1 | tr -d '\n' | sed -e 's% %SCMPVSPACELOL%g' -e 's%[^ ]*<h1SCMPVSPACELOLitemprop="name"><aSCMPVSPACELOLitemprop="url"SCMPVSPACELOLhref="/%%g' -e 's%-[0-9][0-9]-[^ ]*</time>[^ ]*%%g' -e 's%</a>SCMPVSPACELOLbySCMPVSPACELOL<aSCMPVSPACELOLhref="/[^ ]*">% %g' -e 's%</a></h1>[^ ]*te>% %g' -e 's%[^ ]*">%%g')
        num_=0
        for y in $result_array1 ; do
            export echo$num_="$(echo -e "$y" | sed -e 's%[^ ]*">%%g' -e 's%SCMPVSPACELOL% %g')"
            num_=$((num_+1))
        done
        num=$((num+1))
        echo -e "$(tput setaf 7) $num) $echo1 - $echo0 ($echo2)$(tput sgr0)"
    done
    ask-selection
}

search-sets() {
    curl -sL "https://soundcloud.com/search/sets?q=$@" -o $HOME/.cache/scmpv/0
    result_html=$(<$HOME/.cache/scmpv/0)
    result_array=$(echo $result_html | tr -d '\n' | sed -e 's% %SCMPVSPACELOL%g' -e 's%[^ ]*</a></li>SCMPVSPACELOL</ul>SCMPVSPACELOL<ul>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/%%g' -e 's%</a></h2></li>SCMPVSPACELOL<li><h2><aSCMPVSPACELOLhref="/% %g' -e 's%</a>[^ ]*%%g' -e 's%<!DOCTYPESCMPVSPACELOLhtml>[^ ]*%%g')
    if [[ $result_array == "" ]]; then
        echo -e "$(tput setaf 9)Could not find album: $@$(tput sgr0)"
        rm -rf $HOME/.cache/scmpv
        exit 1
    fi
    num=0
    for x in $result_array ; do
        result=$(echo $x | sed 's%">[^ ]*%%g')
        export result$num=$result
        curl -sL "https://soundcloud.com/$result" -o $HOME/.cache/scmpv/1
        result_html1=$(<$HOME/.cache/scmpv/1)
        result_array1=$(echo $result_html1 | tr -d '\n' | sed -e 's% %SCMPVSPACELOL%g' -e 's%[^ ]*<h1SCMPVSPACELOLitemprop="name"><aSCMPVSPACELOLitemprop="url"SCMPVSPACELOLhref="/%%g' -e 's%</a>SCMPVSPACELOLbySCMPVSPACELOL<aSCMPVSPACELOLhref="/% %g' -e 's%</a></[^ ]*%%g' -e 's%[^ ]*/sets/[^ ]*">%%g' -e 's%">% %g')
        num_=0
        for y in $result_array1 ; do
            export echo$num_="$(echo -e "$y" | sed 's%SCMPVSPACELOL% %g')"
            num_=$((num_+1))
        done
        num=$((num+1))
        echo -e "$(tput setaf 7) $num) $echo2($echo1) - $echo0 $(tput sgr0)"
    done
    ask-selection
}

ask-selection() {
    rm -rf $HOME/.cache/scmpv
    printf "$(tput setaf 7)$(tput bold) Type selection:$(tput sgr0) "
    read answer
    case $answer in
        1) if [[ ! $result0 == "" ]] ; then mpv https://soundcloud.com/$result0 ; exit ; fi ;;
        2) if [[ ! $result1 == "" ]] ; then mpv https://soundcloud.com/$result1 ; exit ; fi ;;
        3) if [[ ! $result2 == "" ]] ; then mpv https://soundcloud.com/$result2 ; exit ; fi ;;
        4) if [[ ! $result3 == "" ]] ; then mpv https://soundcloud.com/$result3 ; exit ; fi ;;
        5) if [[ ! $result4 == "" ]] ; then mpv https://soundcloud.com/$result4 ; exit ; fi ;;
        6) if [[ ! $result5 == "" ]] ; then mpv https://soundcloud.com/$result5 ; exit ; fi ;;
        7) if [[ ! $result6 == "" ]] ; then mpv https://soundcloud.com/$result6 ; exit ; fi ;;
        8) if [[ ! $result7 == "" ]] ; then mpv https://soundcloud.com/$result7 ; exit ; fi ;;
        9) if [[ ! $result8 == "" ]] ; then mpv https://soundcloud.com/$result8 ; exit ; fi ;;
        10) if [[ ! $result9 == "" ]] ; then mpv https://soundcloud.com/$result9 ; exit ; fi ;;
    esac
    echo -e "$(tput setaf 1)$(tput bold)Invalid answer$(tput sgr0)"
    exit 1
}


if [[ ! -d "$HOME/.cache/scmpv" ]]; then
mkdir -p $HOME/.cache/scmpv
fi
    
if [[ $1 == "" || $1 == "-h" || $1 == "--help" ]] ; then
    echo -e " scmpv by deimfy"
    echo -e " A dirty soundcloud wrapper for mpv\n"
    echo -e " List of arguments for scmpv:\n"
    echo -e "   track, tracks, sound, sounds, tr, so    Search for specified track"
    echo -e "   people, artist, artists, pe, ar         Search for specified artist"
    echo -e "   album, albums, al                       Search for specified album"
    echo -e "   set, sets, playlist, playlists, st, pl  Search for specified playlist\n"
    exit
fi
argument=$1
shift
search_string=$(echo $@ | sed 's% %+%g')
case "$argument" in
    tr|track|tracks|sounds|sound|so)
        search-tracks $search_string
        ;;
    pe|people|artist|artists|ar)
        search-people $search_string
        ;;
    al|album|albums)
        search-albums $search_string
        ;;
    st|set|sets|playlist|playlists|pl)
        search-sets $search_string
        ;;
    *)  
        echo -e "Unknown argument: $argument"
        ;;
esac
