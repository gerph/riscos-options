# Makefile for Options
#
# ***********************************
# ***    C h a n g e   L i s t    ***
# ***********************************
# Date         Name   Description
# ----         ----   -----------
# 13 Apr 1999  JRF    Created from Toolbox.Scale
#

#
# Component specific options:
#
COMPONENT  = Options
ROM_MODULE = aof.${COMPONENT}
RAM_MODULE = rm.${COMPONENT}

#
# Export Paths for Messages module
#
RESDIR = <resource$dir>.Resources2.${COMPONENT}

#
# Generic options:
#
MKDIR   = cdir
CC      = cc
CD      = dir
CMHG    = cmunge
CP      = copy
MV      = copy
LD      = link
TLD	= tlink
RM      = remove
WIPE    = -wipe
HSC     = hsc


CPFLAGS = ~cfr~v
MVFLAGS = ~cfr~vd
WFLAGS  = ~c~v
HSCFLAGS = getsize rplcent smartent to=../doc/ serverdir=doc BuildHSC:specmacros

#CFLAGS   = -throwback -c -depend !Depend ${INCLUDES} -zM -ffah -zps1 ${DFLAGS}
CFLAGS   = -throwback -c -depend !Depend ${INCLUDES} -zM -g ${DFLAGS}
DFLAGS   =
INCLUDES = -IOSLib:Core.,C:

#
# Libraries
#
ANSILIB   = CLib:o.ansilib
CLIB      = CLIB:o.stubs
RLIB      = RISCOSLIB:o.risc_oslib
ROMCSTUBS = RISCOSLIB:o.romcstubs
ABSSYM    = RISC_OSLib:o.abssym
TBOXLIB   = <Lib$Dir>.tboxlibint.o.tboxlibm

OBJS =\
 o.optlist \
 o.textproc \
 o.strdup \
 o.stricmp \
 o.choices \
 o.options \
 o.module \
 o.veneers
# o.main \

RAM_OBJS =\
 o.optlist \
 o.textproc \
 o.strdup \
 o.stricmp \
 o.choices \
 o.options \
 o.module \
 o.veneers
# o.main \

MSGSF=o.msgs
RESF=o.res

#
# Rule patterns
#
.c.o:;    ${CC} ${CFLAGS} -o $@ $<
.cmhg.o:; ${CMHG} -p -o $@ $<
.cmhg.h:; ${CMHG} -p -d $@ $<

#
# Main rules:
#
#
ram: ${RAM_MODULE}
        @echo ${COMPONENT}: Module built (RAM)

all: ${RAM_MODULE} ${RAM_MODULE} doc.specification
        @echo ${COMPONENT}: All built

docs: doc.specification
        @echo ${COMPONENT}: Documentation built

rom: ${ROM_MODULE}
        @echo ${COMPONENT}: Module built (ROM)

install_rom: ${ROM_MODULE}
        ${CP} ${ROM_MODULE} ${INSTDIR}.${COMPONENT} ${CPFLAGS}
        @echo ${COMPONENT}: Module installed (ROM)

#resources: Resources.${LOCALE}.Messages Resources.${LOCALE}.Res
#        ${MKDIR} ${RESDIR}
#        ${CP} Resources.${LOCALE}.* ${RESDIR}.* ${CPFLAGS}
#        @echo ${COMPONENT}: resource files copied to Messages module

clean:
        ${WIPE} o.* ${WFLAGS}
        ${WIPE} aof ${WFLAGS}
        ${WIPE} rm ${WFLAGS}
        ${WIPE} linked ${WFLAGS}
        ${WIPE} map ${WFLAGS}
        @echo ${COMPONENT}: cleaned

${ROM_MODULE}: ${OBJS} ${TBOXLIB} ${ROMCSTUBS}
        ${MKDIR} aof
        ${LD} -o $@ -aof ${OBJS} ${TBOXLIB} ${ROMCSTUBS}

# final link for ROM Image (using given base address)
rom_link:
        ${MKDIR} linked
        ${MKDIR} map
        ${LD} -o linked.${COMPONENT} -bin -base ${ADDRESS} ${ROM_MODULE} ${ABSSYM} \
              -map > map.${COMPONENT}
        truncate map.${COMPONENT} linked.${COMPONENT}
        ${CP} linked.${COMPONENT} ${LINKDIR}.${COMPONENT} ${CPFLAGS}
        @echo ${COMPONENT}: rom_link complete

#${MSGSF}: @.Resources.${LOCALE}.Messages
#	resgen messages_file ${MSGSF} Resources.${LOCALE}.Messages Resources.${COMPONENT}.Messages

#${RESF}: @.Resources.${LOCALE}.Res
#	resgen res_file ${RESF} Resources.${LOCALE}.Res Resources.${COMPONENT}.Res


${RAM_MODULE}: ${RAM_OBJS} ${CLIB}
	${mkdir} rm
        ${LD} -o $@ -module ${RAM_OBJS} ${CLIB}
        |${LD} -o $@ -aif ${RAM_OBJS} ${CLIB}
        Access $@ RW/R

o.mainRAM: main.c
	$(CC) ${CFLAGS} -o $@ main.c

o.veneers: h.module

doc.specification: docsrc.specification
        $(cd) docsrc
        $(hsc) ${HSCFLAGS} specification
        $(cd) ^
        $(mv) $@/html $@ ${mvflags}

#---------------------------------------------------------------------------
# Dynamic dependencies:
