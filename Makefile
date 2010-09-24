NAME		:= epgsql
VERSION		:= 1.2

ERL  		:= erl
ERLC 		:= erlc

# ------------------------------------------------------------------------

ERLC_FLAGS	:= -Wall -I include

SRC			:= $(wildcard src/*.erl)
TESTS 		:= $(wildcard test_src/*.erl)
RELEASE		:= $(NAME)-$(VERSION).tar.gz

APPDIR		:= $(NAME)-$(VERSION)
APPFILE	:= $(NAME).app
BEAMS		:= $(SRC:src/%.erl=ebin/%.beam) 

PREFIX		?= /usr
ERL_ROOT	:= $(PREFIX)/lib/erlang
LIBDIR		:= /lib

compile: $(BEAMS) ebin/$(APPFILE)

app: compile
	@mkdir -p $(APPDIR)/ebin
	@cp -r ebin/* $(APPDIR)/ebin/
	@cp -r include $(APPDIR)

release: app
	@tar czvf $(RELEASE) $(APPDIR)

clean:
	@rm -f ebin/*.beam
	@rm -f ebin/*.app
	@rm -rf $(NAME)-$(VERSION) $(NAME)-*.tar.gz

install: app
	@mkdir -p $(DESTDIR)$(ERL_ROOT)$(LIBDIR)
	@cp -r $(APPDIR) $(DESTDIR)$(ERL_ROOT)$(LIBDIR)

uninstall:
	@rm -rf $(DESTDIR)$(ERL_ROOT)$(LIBDIR)/$(APPDIR)

test: $(TESTS:test_src/%.erl=test_ebin/%.beam) $(BEAMS)
	@dialyzer --src -c src
	$(ERL) -pa ebin/ -pa test_ebin/ -noshell -s pgsql_tests run_tests -s init stop

# ------------------------------------------------------------------------

.SUFFIXES: .erl .beam
.PHONY:    app compile clean install uninstall test

ebin/%.beam : src/%.erl
	$(ERLC) $(ERLC_FLAGS) -o $(dir $@) $<

test_ebin/%.beam : test_src/%.erl
	$(ERLC) $(ERLC_FLAGS) -o $(dir $@) $<

ebin/%.app : src/%.app
	cp $< $@
