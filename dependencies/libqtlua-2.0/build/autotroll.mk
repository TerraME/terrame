# Makerules.
# This file is part of AutoTroll.
# Copyright (C) 2006  Benoit Sigoure.
#
# AutoTroll is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301,
# USA.

 # ------------- #
 # DOCUMENTATION #
 # ------------- #

# See autotroll.m4 :)


SUFFIXES = .moc.cc .hh \
           .ui .ui.hh \
           .qrc .qrc.cc

# --- #
# MOC #
# --- #

.hh.moc.cc:
	$(MOC) $(QT_CPPFLAGS) `sed -n '/\/ __moc_flags__/ s:// __moc_flags__:: p' "$<"` $< -o $@

# --- #
# UIC #
# --- #

.ui.ui.hh:
	$(UIC) $< -o $@

# --- #
# RCC #
# --- #

.qrc.qrc.cc:
	$(RCC) -name `echo "$<" | sed 's/\.qrc$$//'` $< -o $@

DISTCLEANFILES = $(BUILT_SOURCES)
