#!/usr/bin/env python
# -*- coding: UTF-8 -*-
'''Uso: %s <arquivo_de_entrada> <nome_da_base_de_dados>
Exemplo: para restaurar um backup feito no arquivo xpto.sql.bz2
na base de dados xpto_restore execute:
  %s xpto.sql.bz2 xpto_restore'''

__author__ = 'Pablo Santiago Blum de Aguiar <pablo.aguiar@gmail.com>'
__copyright__ = 'Copyright (c) 2008 Blum-Aguiar'
__license__ = '''Copyright (c) 2008 Blum-Aguiar
Copyright (c) 2008 Pablo Santiago Blum de Aguiar <pablo.aguiar@gmail.com>
All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice,
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice,
      this list of conditions and the following disclaimer in the documentation
      and/or other materials provided with the distribution.
    * Neither the name of the PBA IT Solutions nor the names of its contributors
      may be used to endorse or promote products derived from this software
      without specific prior written permission.

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
import commands

from config import DBConfig

def restoreDatabase(infile, database):
    'Efetua o restore de infile em database'
    if DBConfig['pass'] != '':
        adminUser = '-u %s' % DBConfig['user']
    else:
        adminUser = '-u root'
    if DBConfig['pass'] != '':
        adminPass = '-p%s' % DBConfig['pass']
    else:
        adminPass = ''
    mysqlDump = 'mysql %s %s' % (adminUser, adminPass)
    basename = infile.split('.')
    basename.reverse()
    if len(basename) > 0 and basename[0] == 'sql':
        cmd = '%s %s < %s' % (mysqlDump, database, infile)
    elif len(basename) > 1 and basename[1] == 'sql':
        if basename[0] == 'gz':
            cmd = 'gunzip < %s | %s %s' % (infile, mysqlDump, database)
        elif basename[0] == 'bz2':
            cmd = 'bunzip2 < %s | %s %s' % (infile, mysqlDump, database)
        else:
            print 'Tipo de arquivo não confere com os suportados (.sql, .sql.gz, .sql.bz2)'
            sys.exit(1)
    else:
        print 'Tipo de arquivo não confere com os suportados (.sql, .sql.gz, .sql.bz2)'
        sys.exit(1)
    res = commands.getstatusoutput(cmd)
    if res[0] == 0:
        print 'Backup restaurado do arquivo %s com sucesso!' % infile
    else:
        print 'Erro ao restaurar backup do arquivo %s: %s' % (infile, res[1])

def uso():
    'Mostra como se usa o programa'
    print __doc__ % (sys.argv[0],  sys.argv[0])

def main():
    'Função principal'
    try:
        infile = sys.argv[1] # arquivo de entrada
        databaseName = sys.argv[2] # nome da base de dados
    except IndexError:
        print 'Número de argumentos inválido!'
        uso()
        sys.exit(1)
    restoreDatabase(infile, databaseName)

if __name__ == "__main__":
    main()
