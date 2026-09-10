D2_SRC := $(filter-out %-dark.d2,$(wildcard diagrams/*.d2))
SVGS   := $(D2_SRC:.d2=.svg) $(D2_SRC:.d2=-dark.svg)

all: index.html

index.html: index.src.html $(SVGS) build.py
	./build.py

diagrams/%.svg: diagrams/%.d2
	d2 --theme 0 --pad 20 $< $@

clean:
	rm -f index.html diagrams/*.svg

.PHONY: all clean
