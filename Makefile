PREFIX ?= /usr
LIBDIR ?=
ifeq ($(LIBDIR),)
ARCHBSZ= $(shell echo $(HOST_ARCH) | sed -e 's/.*64.*/64b/')
ifeq ($(ARCHBSZ),64b)
	LIBDIR = lib64
else
	LIBDIR = lib
endif
endif
INSTALLDIR = $(DESTDIR)$(PREFIX)

LIBRARY = libgscgi-1.0.so

SRC = Request.vala Server.vala
PKGS = --pkg=gio-2.0

VALAC = valac
VALACOPTS = -g --library libgscgi-1.0 -X -shared -X -fPIC -H libgscgi-1.0.h

all: $(LIBRARY)

$(LIBRARY):
	@echo "VALAC"
	@$(VALAC) $(VALACOPTS) $(SRC) -o $(LIBRARY) $(PKGS)

install: $(LIBRARY) libgscgi-1.0.deps
	@echo "Installing"
	@mkdir -p $(INSTALLDIR)/share/vala/vapi
	@mkdir -p $(INSTALLDIR)/share/pkgconfig
	@install -m 755 -d $(INSTALLDIR)/lib/pkgconfig/ $(INSTALLDIR)/include/ $(INSTALLDIR)/share/vala/vapi
	@install -m 755 $(LIBRARY) $(INSTALLDIR)/$(LIBDIR)/
	@install -m 644 libgscgi-1.0.h $(INSTALLDIR)/include/
	@install -m 644 libgscgi-1.0.vapi $(INSTALLDIR)/share/vala/vapi
	@install -m 644 libgscgi-1.0.deps $(INSTALLDIR)/share/vala/vapi
	@sed -e 's/@LIBDIR@/$(subst /,\/,$(INSTALLDIR))\/$(LIB_DIR)/' -e 's/@INCLUDEDIR@/$(subst /,\/,$(INSTALLDIR))\/include/' libgscgi-1.0.pc.in > $(INSTALLDIR)/share/pkgconfig/libgscgi-1.0.pc

clean:
	@echo "Cleaning"
	@rm -v -fr *~ *.c $(LIBRARY) *.vapi *.h

.PHONY: clean all install
