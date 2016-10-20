#lang scribble/manual

@(require (for-label base32))
@title[#:tag "base32"]{Base 32: Encoding and Decoding}

@defmodule[base32]{The @racketmodname[base32] library provides
utilities for Base 32 encoding and decoding.}

@section[#:tag "base32-procs"]{Functions}

@defproc[(base32-encode [bstr bytes?] [newline-bstr bytes? #"\r\n"]) bytes?]{

Consumes a byte string and returns its Base 32 encoding as a new byte
string.  The returned string is broken into 72-byte lines separated by
@racket[newline-bstr], which defaults to a CRLF combination, and the
result always ends with a @racket[newline-bstr] unless the
input is empty.}


@defproc[(base32-decode [bstr bytes?]) bytes?]{

Consumes a byte string and returns its Base 32 decoding as a new byte
string.}


@defproc[(base32-encode-stream [in input-port?]
                               [out output-port?]
                               [newline-bstr bytes? #"\n"])
         void?]{

Reads bytes from @racket[in] and writes the encoded result to
@racket[out], breaking the output into 72-character lines separated by
@racket[newline-bstr], and ending with @racket[newline-bstr] unless
the input stream is empty. Note that the default @racket[newline-bstr]
is just @racket[#"\n"], not @racket[#"\r\n"]. The procedure returns when
it encounters an end-of-file from @racket[in].}

@defproc[(base32-decode-stream [in input-port?]
                               [out output-port?])
         void?]{

Reads a Base 32 encoding from @racket[in] and writes the decoded
result to @racket[out]. The procedure returns when it encounters an
end-of-file or Base 32 terminator @litchar{=} from @racket[in].}

