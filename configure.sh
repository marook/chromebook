#!/bin/bash

set -e

MAKEFILE='Makefile.gen'

read_value(){
    local const_name="$1"
    local default_value="$2"
    local prompt="$3"

    read -p "${prompt} [${default_value}]: " ${const_name}

    if [ -z "${!const_name}" ]
    then
        export ${const_name}="${default_value}"
    fi
}

find_theme(){
    local theme_name="$1"

    for themes_dir in ~/.themes /usr/share/themes
    do
        local theme_dir="${themes_dir}/${theme_name}"

        if [ -d "${theme_dir}" ]
        then
            echo "${theme_dir}"

            return 0
        fi
    done
}

get_master_theme_dir(){
    echo 'The chromebook theme is generated by extending existing themes. Choose which theme you would like to extend.'

    get_theme_dir 'Gtk theme' 'gtk_theme_dir' 'Clearlooks'
    get_theme_dir 'xfce theme' 'xfce_theme_dir' 'Default-4.0'
}

get_theme_dir(){
    local theme_type="$1"
    local theme_dir_var="$2"
    local default_theme="$3"

    while [ 1 ]
    do
        read_value 'theme_name' "${default_theme}" "${theme_type}"

        local theme_dir=`find_theme "${theme_name}"`

        if [ -z "${theme_dir}" ]
        then
            echo "Can't find ${theme_type} '${theme_name}'."
        else
            export ${theme_dir_var}="${theme_dir}"
            
            break
        fi
    done
}

append(){
    echo "$1" >> "${MAKEFILE}"
}

append_copy_rule(){
    src="$1"
    dst="$2"

    append ''
    append "${dst}: ${src}"
    append '	mkdir -p `dirname "$@"`'
    append '	cp "$^" "$@"'
}

# I took this function from http://stackoverflow.com/a/5027832
get_relative_path(){
    source="$1"
    target="$2"

    common_part=$source
    back=
    while [ "${target#$common_part}" = "${target}" ]; do
        common_part=$(dirname $common_part)
        back="../${back}"
    done

    echo ${back}${target#$common_part/}
}

append_merge_rule(){
    local dst="$1"
    local src1="$2"
    local src2="$3"
    
    append ''
    append "${dst}: ${src1} ${src2}"
    append '	mkdir -p `dirname "$@"`'
    append '	cat $^ > "$@"'
}

append_image_scale_rule(){
    dst="$1"
    src="$2"

    append ''
    append "${dst}: ${src}"
    append '	mkdir -p `dirname "$@"`'
    append '	convert "$^" -resize 200% "$@"'
}

generate_makefile(){
    all_theme_files=

    # make the former Makefile empty
    echo -n '' > "${MAKEFILE}"

    append_theme_rules "${gtk_theme_dir}" "${gtk_theme_dir}/gtk-2.0"
    append_theme_rules "${xfce_theme_dir}" "${xfce_theme_dir}/xfwm4"

    append ''
    append "ALL_THEME_FILES=${all_theme_files}"
}

append_theme_rules(){
    local theme_dir="$1"
    local theme_files_dir="$2"

    for master_theme_file in `find "${theme_files_dir}" -type f`
    do
        local rel_theme_file_path=`get_relative_path ${theme_dir} ${master_theme_file}`
        local install_dest_file_path="\${THEME_INSTALL_DIR}/${rel_theme_file_path}"

        case "${rel_theme_file_path}" in
            gtk-2.0/gtkrc)
                append_merge_rule "${install_dest_file_path}" "${master_theme_file}" "src/gtkrc-2.0"
                ;;
            *.xpm)
                append_image_scale_rule "${install_dest_file_path}" "${master_theme_file}"
                ;;
            *)
                append_copy_rule "${master_theme_file}" "${install_dest_file_path}"
                ;;
        esac

        all_theme_files="${all_theme_files} ${install_dest_file_path}"
    done
}

get_master_theme_dir
generate_makefile
