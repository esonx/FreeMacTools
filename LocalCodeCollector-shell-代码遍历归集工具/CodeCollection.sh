#!/bin/bash

#==============================================================================
# Filename: code_collector.sh
# Version: 1.0.0
# Created: 2024-10-29
# Last Updated: 2024-10-29
# Author: Claude, Ethan Liu
# 
# Description:
#   This script is used to collect and consolidate all code files from a specified 
#   directory into a single output file. It can recursively search directories, 
#   supports specifying file extensions, can optionally remove empty lines, and 
#   marks each file's absolute path at the beginning.
#   Uses standard bash syntax and is compatible with macOS (find, sed, realpath, etc.)
#
# Features:
#   1. Recursively search for all files with specified extensions in the current directory
#   2. Supports custom output file path and name
#   3. Adds a [FILE_PATH] tag before the content of each file
#   4. Optionally removes empty lines
#   5. Uses absolute paths for file tagging
#
# Usage:
#   ./code_collector.sh [-e extension] [-o output_file] [-r] [-h]
#
# Parameter Descriptions:
#   -e    Specify file extension (default: java)
#   -o    Specify output file (default: collected_code.txt)
#   -r    Remove empty lines
#   -h    Display help information
#
# Usage Examples:
#   Basic usage:
#     ./code_collector.sh
#   
#   Specify Python files and remove empty lines:
#     ./code_collector.sh -e py -o output.txt -r
#   
#   Process Java files with a custom output path:
#     ./code_collector.sh -e java -o /Users/username/Desktop/collected.txt
#
# Required Commands:
#   - find
#   - sed
#   - realpath
#   - cat
#
# Return Values:
#   0  - Success
#   1  - Failure (invalid parameters or files not found)
#
# Notes:
#   1. Ensure the script has execution permissions (chmod +x code_collector.sh)
#   2. The output file will be overwritten if it already exists
#   3. It’s recommended to back up important data before use
#
# License:
#   MIT License
#==============================================================================

#==============================================================================
# 文件名: code_collector.sh
# 版本号: 1.0.0
# 创建日期: 2024-10-29
# 最后更新: 2024-10-29
# 作者: Claude,Ethan Liu
# 
# 描述:
#   这个脚本用于收集并整合指定目录下的所有代码文件到一个输出文件中。
#   它可以递归搜索目录，支持指定文件扩展名，可以选择性地删除空行，
#   并在每个文件的开始处标记其绝对路径。
#   使用标准 bash 语法,兼容 macOS  (find, sed, realpath等)
#
# 功能:
#   1. 递归搜索当前目录下所有指定后缀的文件
#   2. 支持自定义输出文件路径和名称
#   3. 在每个文件内容前添加【FILE_PATH】标记
#   4. 可选择是否删除空行
#   5. 使用绝对路径进行文件标记
#
# 使用方法:
#   ./code_collector.sh [-e extension] [-o output_file] [-r] [-h]
#
# 参数说明:
#   -e    指定文件扩展名 (默认: java)
#   -o    指定输出文件 (默认: collected_code.txt)
#   -r    删除空行
#   -h    显示帮助信息
#
# 使用示例:
#   基本使用:
#     ./code_collector.sh
#   
#   指定Python文件并删除空行:
#     ./code_collector.sh -e py -o output.txt -r
#   
#   处理Java文件并自定义输出路径:
#     ./code_collector.sh -e java -o /Users/username/Desktop/collected.txt
#
# 依赖命令:
#   - find
#   - sed
#   - realpath
#   - cat
#
# 返回值:
#   0  - 执行成功
#   1  - 执行失败（参数错误或未找到文件）
#
# 注意事项:
#   1. 确保脚本具有执行权限（chmod +x code_collector.sh）
#   2. 输出文件如果已存在会被覆盖
#   3. 建议在使用前备份重要数据
#
# 许可证:
#   MIT License
#==============================================================================


# Default value settings
output_file="collected_code.txt"
file_extension="java"
remove_empty_lines=false

# Display usage
usage() {
    echo "Usage: $0 [-e extension] [-o output_file] [-r] [-h]"
    echo "Options:"
    echo "  -e    Specify file extension (default: java)"
    echo "  -o    Specify output file (default: collected_code.txt)"
    echo "  -r    Remove empty lines"
    echo "  -h    Display help information"
    exit 1
}

# Process command-line arguments
while getopts "e:o:rh" opt; do
    case $opt in
        e) file_extension="$OPTARG";;
        o) output_file="$OPTARG";;
        r) remove_empty_lines=true;;
        h) usage;;
        ?) usage;;
    esac
done

# Ensure the output file uses an absolute path
if [[ "$output_file" != /* ]]; then
    output_file="$(pwd)/$output_file"
fi

# Create a temporary file
temp_file=$(mktemp)

# Find all files with the specified extension and process them
find "$(pwd)" -type f -name "*.$file_extension" | while read -r file; do
    # Ensure the file path is absolute
    abs_path=$(realpath "$file")
    
    # Add the file path as a separator
    echo "[FILE_PATH] $abs_path" >> "$temp_file"
    
    if [ "$remove_empty_lines" = true ]; then
        # Remove empty lines and retain other content
        sed '/^[[:space:]]*$/d' "$file" >> "$temp_file"
    else
        cat "$file" >> "$temp_file"
    fi
    
    # Add a newline as a separator between files
    echo -e "\n" >> "$temp_file"
done

# Check if any files were found
if [ ! -s "$temp_file" ]; then
    echo "Error: No .$file_extension files found"
    rm "$temp_file"
    exit 1
fi

# Move the temporary file to the target file
mv "$temp_file" "$output_file"

echo "Code collection complete!"
echo "Output file: $output_file"