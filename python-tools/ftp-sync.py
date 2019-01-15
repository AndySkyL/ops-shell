#!/usr/bin/python

from ftplib import FTP
import os

local_base_dir = r'D:\temp\test'   # windows
# local_base_dir = '/home/jenkins'  # Linux
remote_base_dir = '/jenkins'
project_list = os.listdir(local_base_dir)


def local_new_files(local_base_dir):
    file_list = os.listdir(local_base_dir)
    # file_list.sort(key=lambda fn: os.path.getmtime(local_base_dir + '/' + fn))  # Linux
    file_list.sort(key=lambda fn: os.path.getmtime(local_base_dir + '\\' + fn))  # windows
    return file_list


# 登录FTP
def loginftp(host_ip='192.168.1.1', user='root', password='123456'):
    ftp = FTP(host_ip)
    ftp.login(user, password)
    return ftp


# 获取ftp文件目录信息
def ftp_file(ftp, remote_base_dir):
    ftp.cwd(remote_base_dir)
    ftp_files = ftp.nlst()
    return ftp_files, remote_base_dir

# 比对基础项目文件目录
def base_dir_compare(local_base_dir, ftp):
    local_dir_list = local_new_files(local_base_dir)
    ftp_file_list, dirpath = ftp_file(ftp, remote_base_dir)
    ftp.cwd(dirpath)
    local_project_base_list = []
    ftp_project_base_list = []

    for base in local_dir_list:
        if os.path.isfile(os.path.join(local_base_dir, base)): continue
        if base not in ftp_file_list:
            ftp.mkd(base)
        local_project_base_list.append(os.path.join(local_base_dir, base))
        ftp_project_base_list.append(os.path.join(dirpath, base))
    return ftp_project_base_list, local_project_base_list

# 比对版本目录
def project_dir_compare(local_base_dir, ftp):
    ftp_pro_base_list, local_pro_base_list = base_dir_compare(local_base_dir, ftp)
    local_versions_list = []
    ftp_versions_list = []
    n = 0
    while (n < len(local_pro_base_list)):

        local_versions = local_new_files(local_pro_base_list[n])[-3:]
        ftp_versions, remote_base_dir = ftp_file(ftp, ftp_pro_base_list[n])
        for version in local_versions:
            if version not in ftp_versions and os.path.isdir(os.path.join(local_pro_base_list[n], version)):
                ftp.cwd(remote_base_dir)
                ftp.mkd(version)
                local_versions_list.append(os.path.join(local_pro_base_list[n], version))
                ftp_versions_list.append(os.path.join(ftp_pro_base_list[n], version))
        n += 1
    print(local_versions_list, ftp_pro_base_list)
    return ftp_versions_list, local_versions_list


# 递归上传文件
def ftp_upload(local_path, ftp_path, ftp):
    if os.path.isdir(local_path):
        local_list = os.listdir(local_path)
        print(ftp_path)
        for dir in local_list:
            if os.path.isdir(os.path.join(local_path, dir)):
                ftp.cwd(ftp_path)
                ftp.mkd(dir)
            ftp_upload(os.path.join(local_path, dir), os.path.join(ftp_path, dir), ftp)

    elif os.path.exists(local_path):
        ftp.cwd(os.path.dirname(ftp_path))
        filename = os.path.basename(local_path)
        print(local_path)
        print(ftp_path)
        file = open(local_path, 'rb')
        ftp.storbinary('STOR %s' % filename, file, 2048)
        file.close()


if __name__ == '__main__':
    remote_base_dir = '/jenkins'
    ftp = loginftp()
    ftp_versions_list, local_versions_list = project_dir_compare(local_base_dir, ftp)
    count = 0
    while count < len(local_versions_list):
        ftp_upload(local_versions_list[count], ftp_versions_list[count], ftp)
        count += 1
    ftp.close()

