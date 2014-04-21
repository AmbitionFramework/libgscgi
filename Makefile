ifeq ($(DESTDIR),)
else
PREFIX = $(DESTDIR)
endif
ifeq ($(PREFIX),)
PREFIX = /usr
endif
LIBDIR ?=
ifeq ($(LIBDIR),)
ARCHBSZ= $(shell echo $(HOST_ARCH) | sed -e 's/.*64.*/64b/')
ifeq ($(ARCHBSZ),64b)
	LIBDIR = lib64
else
	LIBDIR = lib
endif
endif

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
	@mkdir -p $(PREFIX)/share/vala/vapi
	@mkdir -p $(PREFIX)/share/pkgconfig
	@install -m 755 -d $(PREFIX)/lib/pkgconfig/ $(PREFIX)/include/ $(PREFIX)/share/vala/vapi
	@install -m 755 $(LIBRARY) $(PREFIX)/$(LIBDIR)/
	@install -m 644 libgscgi-1.0.h $(PREFIX)/include/
	@install -m 644 libgscgi-1.0.vapi $(PREFIX)/share/vala/vapi
	@install -m 644 libgscgi-1.0.deps $(PREFIX)/share/vala/vapi
	@sed -e 's/@LIBDIR@/$(subst /,\/,$(PREFIX))\/$(LIB_DIR)/' -e 's/@INCLUDEDIR@/$(subst /,\/,$(PREFIX))\/include/' libgscgi-1.0.pc.in > $(PREFIX)/share/pkgconfig/libgscgi-1.0.pc

uninstall:
	@echo "Uninstalling"
	@rm $(PREFIX)/lib/$(LIBRARY)
	@rm $(PREFIX)/include/libgscgi-1.0.h
	@rm $(PREFIX)/share/vala/vapi/libgscgi-1.0.vapi
	@rm $(PREFIX)/lib/pkgconfig/libgscgi-1.0.pc

clean:
	@echo "Cleaning"
	@rm -v -fr *~ *.c $(LIBRARY) *.vapi *.h

.PHONY: clean all install
