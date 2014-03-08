#!/usr/bin/env python
# -*- coding: UTF-8 -*-
'''
Script cronjob para agendamento de backup sequencial de banco de dados
A política de backup adotada é a seguinte:
 - Backups diários
 - Rotação semanal
 - Cópia de backup da semana anterior
 - Backup mensal no dia 28
'''

__author__ = 'Pablo Santiago Blum de Aguiar <pablo.aguiar@gmail.com>'
__copyright__ = 'Copyright (c) 2008-2013 Blum-Aguiar'
__license__ = '''Copyright (c) 2008-2013 Blum-Aguiar
Copyright (c) 2008-2013 Pablo Santiago Blum de Aguiar <pablo.aguiar@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of the Blum-Aguiar nor the names of its contributors may be
      used to endorse or promote products derived from this software without
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.'''

import sys
import datetime
import os
import commands

# Script de backup a ser usado
backupScript = '/home/avro/bin/backup/efetua_backup.py'

# Diretório que armazena os arquivos de backup
bakDir = '/home/avro/backup'

# Nome da base de dados a ser backupeada
dataBase = 'avro_dx_new'

# Nome dos dias da semana para nomenclatura dos arquivo
weekDays = {
    0: 'seg',
    1: 'ter',
    2: 'qua',
    3: 'qui',
    4: 'sex',
    5: 'sab',
    6: 'dom'
}


def renameFile(backupFile):
    'Renomeia o arquivo de backup existente adicionando a extensão .old'
    try:
        os.rename(backupFile, '%s.old' % backupFile)
    except OSError, details:
        if details[0] != 2:
            print 'Erro renomeando %s para %s.old: %s' % (backupFile, backupFile, details)
    except Exception, details:
        print 'Erro renomeando %s para %s.old: %s' % (backupFile, backupFile, details)


def doBackup(backupScript, dataBase, backupFile):
    'Efetua o backup com chamada de sistema ao script de backup'
    cmd = '%s %s %s' % (backupScript, dataBase, backupFile)
    res = commands.getstatusoutput(cmd)
    if res[0] != 0:
        print 'Erro ao gerar %s: %s' % (backupFile, res[1])


def monthBackup(bakDir, context, backupFile):
    'Cria backup mensal no dia 28 do mês'
    monthDay = datetime.date.today().day
    if monthDay == 28:
        try:
            from shutil import copy
            month = datetime.date.today().month
            suffix = '.'.join(backupFile.split('.')[-2:])
            monthBackupFile = '%s/%s-mes%0.2d.%s' % (bakDir, context, month, suffix)
            if os.path.exists(monthBackupFile):
                renameFile(monthBackupFile)
            copy(backupFile, monthBackupFile)
        except OSError, details:
            if details[0] != 1:
                print 'Erro[1] ao criar %s: %s' % (monthBackupFile, details)
        except Exception, details:
            print 'Erro[2] ao criar %s: %s' % (monthBackupFile, details)
            print sys.exc_info()[0]


def doPicsBackup(picsDir, picsBackupFile):
    'Efetua o backup das figuras com chamada de sistema ao tar'
    cmd = 'tar cjspf %s -C %s ./' % (picsBackupFile, picsDir)
    res = commands.getstatusoutput(cmd)
    if res[0] != 0:
        print 'Erro ao gerar %s: %s' % (picsBackupFile, res[1])


def main():
    'Função principal'
    if not os.path.isdir(bakDir):
        print '%s não existe ou não é diretório!' % bakDir
        sys.exit(1)
    weekDay = weekDays[datetime.date.today().weekday()]
    backupFile = '%s/%s-%s.sql.bz2' % (bakDir, dataBase, weekDay)
    renameFile(backupFile)
    doBackup(backupScript, dataBase, backupFile)
    monthBackup(bakDir, dataBase, backupFile)
    try:
        picsDir = sys.argv[1]  # diretório de figuras
    except IndexError:
        picsDir = os.getcwd()  # diretório de figuras
    if not os.path.isdir(picsDir + '/entries') or not os.path.isdir(picsDir + '/definitions'):
        print 'Diretórios de figuras não encontrados!'
        sys.exit(1)
    picsBackupFile = '%s/pictures-%s.tar.bz2' % (bakDir, weekDay)
    renameFile(picsBackupFile)
    doPicsBackup(picsDir, picsBackupFile)
    monthBackup(bakDir, 'pictures', picsBackupFile)


if __name__ == "__main__":
    main()
