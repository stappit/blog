IMGDIR=images
TIKZDIR=tikz
AUX=$(TIKZDIR)/aux
TIKZ=$(wildcard $(TIKZDIR)/*.tex)
TIKZPNGS=$(TIKZ:%.tex=%.pdf.png)
PNGS=$(TIKZPNGS:$(TIKZDIR)/%=$(IMGDIR)/%)
TIKZIMGS=$(wildcard $(TIKZDIR)/*.pdf.png)

TREESTYLE=$(TIKZDIR)/tree.tikz
RBSTYLE=$(TIKZDIR)/red-black.tikz
RBTREES=$(wildcard $(TIKZDIR)/red-black*.tex)
BINTREES=$(wildcard $(TIKZDIR)/binomial*.tex)
LEFTISTTREES=$(wildcard $(TIKZDIR)/leftist-tree*.tex)

all: $(PNGS)

$(BINTREES): $(TREESTYLE)
	@touch $@

$(LEFTISTTREES): $(TREESTYLE)
	@touch $@

$(RBTREES): $(RBSTYLE) $(TREESTYLE)
	@touch $@

$(IMGDIR)/%.pdf.png: $(TIKZDIR)/%.tex
	@cd $(TIKZDIR) && latexmk $(^F) && cd .. && convert -density 600x600 $(AUX)/$(^F:%.tex=%.pdf) -quality 90 -resize 1080x800 $@

clean:
	rm -r $(AUX)

rebuild:
	@cp -r _site/.git tmp && ./site rebuild && mv tmp _site/.git
