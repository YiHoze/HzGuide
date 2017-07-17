\ProvidesClass{hzfolio}[2016/08/19]

\LoadClass{minimal}

\RequirePackage{xparse, expl3}
\RequirePackage{graphicx}
\RequirePackage[a4paper]{geometry}
\RequirePackage{pdfpages}
%%\includepdfset{nup=2x1, booklet, pages=-}
\includepdfset{nup=2x1, pages=-}
%%\includepdf[]{}

%%\geometry{
%%	papersize={317mm, 230mm}, 
%%	layoutsize={297mm, 210mm},
%%	margin={0pt, 0pt},
%%	layoutoffset={10mm, 10mm}, 
%%	showcrop
%%}

\setlength\fboxsep{0pt}
\setlength\parindent{0pt}

\ExplSyntaxOn
\keys_define:nn {hzfolio}
{
	scale	.tl_set:N = \page_scale,
	column	.int_set:N = \page_break,
	last	.int_set:N = \page_last,
	hspace	.dim_set:N = \page_hspace,
	vspace	.code:n = { \page_vspace_set:n {#1} },
	frame	.bool_set:N	= \page_frame,
}
\tl_new:N \file_target
\int_new:N \page_logic
\int_new:N \page_real
\int_new:N \page_back_position
\dim_new:N \page_vspace

\cs_new:Npn \page_vspace_set:n #1
{
	\dim_set:Nn \page_vspace {-\baselineskip+#1}
}

\NewDocumentCommand \IncludePagesSetup { m }
{
	\keys_set:nn { hzfolio } {#1}
}

\IncludePagesSetup{
	column=2,
	last=4,
	scale=1, 
	hspace=0pt, 
	vspace=-0.1pt
}

\cs_new:Npn \page_include:n #1
{
	\hspace{\page_hspace}
	\bool_if:NTF \page_frame
		{ \fbox{\includegraphics[scale=\page_scale, page=#1]{\file_target}} }
		{ \includegraphics[scale=\page_scale, page=#1]{\file_target} }
	\int_compare:nTF {\int_mod:nn {\page_logic}{\page_break} = 0 }	
	{
		\int_compare:nT { \page_logic < \page_last }
			{ \vspace{\page_vspace} \newline }
	}{
		\hspace{\page_hspace}
	}

}

%%\IncludePages[options][file]
%%\IncludePages* puts the last page so that it is located on the opposite side of the fist page.
\NewDocumentCommand \IncludePages { s O{} m }
{
	\IncludePagesSetup{#2}
	\tl_set:Nn \file_target {#3}

	\int_compare:nTF { \page_last = 4 }
		{ \int_set:Nn \page_back_position {1} }
		{ \int_set:Nn \page_back_position { \page_break + 1 } }

	\int_do_until:nn { \page_logic = \page_last }
	{
		\int_incr:N \page_logic
		\int_incr:N \page_real
		\IfBooleanT {#1}
		{
			\int_compare:nT { \page_logic = \page_back_position } 
			{ 
				\page_include:n { \page_last }
				\int_incr:N \page_logic
			}
		}
		\page_include:n { \page_real }		
	}
}
\ExplSyntaxOff

