import sys, pymupdf, os, glob
src, out = sys.argv[1], sys.argv[2]
os.makedirs(out, exist_ok=True)
for f in sorted(glob.glob(os.path.join(src, '*.svg'))):
    pymupdf.open(f)[0].get_pixmap(dpi=90).save(os.path.join(out, os.path.basename(f)[:-4] + '.png'))
