library(magick)

e1   <- image_read_pdf("e1.pdf", density = 600)
e2   <- image_read_pdf("e2.pdf", density = 600)
einf <- image_read_pdf("e-infty.pdf", density = 600)

combined <- image_append(c(einf, e2, e1), stack = TRUE)

image_write(combined, path = "Fig2.pdf", format = "pdf", quality = 100)
image_write(combined, path = "Fig2.tiff", format = "tiff", compression = "lzw")
