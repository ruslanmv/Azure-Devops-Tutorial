# FAQ

### Does `safe_filename` remove accents?

It normalizes with Unicode NFKD and keeps only printable characters. Accents are typically decomposed, resulting in ASCII-like filenames.

### Can I force an extension?

Yes—append your own after calling `safe_filename("name", keep_extension=False)`.

### Why not `tempfile.NamedTemporaryFile(delete=False)`?

`atomic_write_*` needs the temp file in the **same directory** as the final target to guarantee atomic replacement.
