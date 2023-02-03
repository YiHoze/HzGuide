\ProvidesClass{hzbeamer}[2017/09/06]
\RequirePackage{xparse, l3keys2e}

\ExplSyntaxOn

\keys_define:nn { hzbeamer }
{
	flier	.bool_set:N = \g_flier_bool,
	hangul	.bool_set:N = \g_hangul_bool
}

\ProcessKeysOptions { hzbeamer }

\NewDocumentCommand \IfFlier { m o }
{
	\bool_if:NTF \g_flier_bool 
	{ 
		#1 
	}{ 
		\IfValueT {#2} {#2} 
	}
}

\NewDocumentCommand \IfSlide { m o }
{
	\bool_if:NTF \g_flier_bool
	{ 
		\IfValueT {#2} {#2}  
	}{ 
		#1
	}
}

\NewDocumentCommand \IfHangul { m o }
{
	\bool_if:NTF \g_hangul_bool
	{ 
		#1 
	}{ 
		\IfValueT {#2} {#2} 
	}
}

\clist_new:N \g_tex_files_clist
\NewDocumentCommand \InputOnly { m }
{
	\clist_gput_right:Nn \g_tex_files_clist {#1}
}
\NewDocumentCommand \Input { m }
{
	\clist_if_empty:NTF \g_tex_files_clist
	{
		\input{#1}
	}{
		\clist_if_in:NnT \g_tex_files_clist {#1} 
		{
			\input{#1}
		}
	}
}

\ExplSyntaxOff

\IfSlide{
	\DeclareOption*{\PassOptionsToClass{\CurrentOption}{beamer}}
	\ProcessOptions	
	\LoadClass[xcolor={svgnames,table}]{beamer}
	\usetheme{metropolis}
	\metroset{
		inner/sectionpage=none, 
		%%outer/progressbar=head,
		outer/numbering=none,
		color/block=transparent
	}	
}[
	\LoadClassWithOptions{article}
	\RequirePackage{geometry}
	\geometry{a4paper, textwidth=15cm, textheight=25cm}
	\RequirePackage[noxcolor, hyperref]{beamerarticle}	
	\RequirePackage[svgnames,table]{xcolor}	
]

\RequirePackage{iftex}
\RequirePackage{fontspec}
\RequirePackage{bookmark}
\RequirePackage{etoolbox}
\RequirePackage{environ}
\RequirePackage{graphicx}
\RequirePackage{tikz}
\RequirePackage{tcolorbox}
\RequirePackage{tabularray}
\RequirePackage{tabto}
\RequirePackage{pdfpages}
\includepdfset{nup=2x1}
%%\RequirePackage[yyyymmdd]{datetime}
%%\renewcommand\dateseparator{-}

%% fonts
\setmainfont{TeX Gyre Pagella}
\setsansfont{TeX Gyre Heros}
\setmonofont{Latin Modern Mono}

\IfHangul{
	\RequirePackage{kotex}
	% \setsanshanjafont{Noto Sans CJK KR}[BoldFont={* Medium}]	
	% \setmainfont{Noto Serif}
	% \setsansfont{Noto Sans}
	% \setmainhangulfont{Noto Serif CJK KR}[BoldFont={* Medium}]	
	% \setsanshangulfont{Noto Sans CJK KR}[BoldFont={* Medium}]	
	\setmainfont{Noto Sans CJK KR}[BoldFont={* Medium}]	
    \setmonohangulfont{Noto Sans Mono CJK KR}
}

% Bookmark frame titles
% \apptocmd{\beamer@@frametitle}{\bookmark[page=\the\c@page,level=3]{##1}}%
% {\message{** patching of \string\beamer@@frametitle succeeded **}}%
% {\message{** patching of \string\beamer@@frametitle failed **}}

\newcommand\justified{\rightskip\z@skip\leftskip\z@skip}

\ExplSyntaxOn
\NewDocumentCommand \narrative {s}
{
	\IfBooleanTF{#1} {\normalsize} {\small}
	\justified
}

%% division
\NewDocumentCommand \Section {s o m}
{
	\IfValueTF{#2}{
		\section{#2}
	}{
		\section{#3}
	}	
	\IfBooleanF{#1}
	{
		\begin{frame}[standout]
		#3
		\end{frame}
	}	
}

\bool_new:N \g_extra_bool

\NewDocumentCommand \ShowExtra { } 
{ 
	\bool_gset_true:N \g_extra_bool 
}

\NewDocumentCommand \HideExtra { } 
{ 
	\bool_gset_false:N \g_extra_bool 
}

\NewDocumentCommand \extra { +m } 
{ 
	\bool_if:NT \g_extra_bool { #1 } 
}
\NewEnviron{Extra}{\extra{\BODY}}
\ShowExtra

\bool_new:N \g_speech_bool

\NewDocumentCommand \ShowSpeech { } 
{ 
	\bool_gset_true:N \g_speech_bool 
}

\NewDocumentCommand \HideSpeech { } 
{ 
	\bool_gset_false:N \g_speech_bool 
}

\NewDocumentCommand \speak { s +m }
{
	\bool_if:NT \g_speech_bool
	{
		\group_begin:
		\setbeamercolor{background~canvas}{
			use=palette~primary,
			parent=palette~primary
		}
		\begin{frame}{}
			\usebeamercolor[fg]{palette~primary}
			\IfBooleanTF {#1}
				{ \narrative* #2 }
				{ \begin{center} \large #2 \end{center} }        			
		\end{frame}
  		\group_end:
  	}
}
\NewEnviron{speech*}{\speak{\BODY}}
\NewEnviron{speech}{\speak*{\BODY}}
\ShowSpeech

%% images
\tl_new:N \g_lineimg_scale
\NewDocumentCommand \LineimgScale { m }
{
	\tl_set:Nn \g_lineimg_scale {#1}
}
\LineimgScale{1}

\NewDocumentCommand \lineimg { o m O{-.25\height} }
{
	\IfValueTF {#1}
		{ \tl_set:Nn \l_tmpa_tl {#1} }
		{ \tl_set:Nx \l_tmpa_tl { \g_lineimg_scale } }
	\raisebox{#3}{\includegraphics[scale=\l_tmpa_tl]{#2}}
}

\newtcolorbox{rulebox}{colframe=gray, colback=white, arc=.25ex, boxrule=.75pt, boxsep=0pt}

\dim_new:N \g_image_width
\dim_new:N \g_image_height
\IfSlide
{
	\dim_gset:Nn \g_image_width {.9\textwidth}
	\dim_gset:Nn \g_image_height {.8\textheight}
}[
	\dim_gset:Nn \g_image_width {.8\textwidth}
	\dim_gset:Nn \g_image_height {.3\textheight}
]

\NewDocumentCommand \image {s t| o m}
{
	\IfBooleanTF{#1}
	{
		\IfNoValueTF{#3}
			{ \dim_set:Nn \l_tmpa_dim {\g_image_height} }
			{ \dim_set:Nn \l_tmpa_dim {#3\textheight} }
		\hbox_set:Nn \l_tmpa_box { \includegraphics[height=\l_tmpa_dim]{#4} }		
	}{
		\IfNoValueTF{#3}
			{ \dim_set:Nn \l_tmpa_dim {\g_image_width} }
			{ \dim_set:Nn \l_tmpa_dim {#3\textwidth} }
		\hbox_set:Nn \l_tmpa_box { \includegraphics[width=\l_tmpa_dim]{#4} }		
	}
	\dim_set:Nn \l_tmpa_dim { \box_wd:N \l_tmpa_box }
	\begin{center}
		\begin{minipage}{1.1\l_tmpa_dim}
			\IfBooleanTF {#2}
			{ \begin{rulebox} \box_use:N \l_tmpa_box \end{rulebox} }
			{ \box_use:N \l_tmpa_box }
		\end{minipage}
	\end{center}
}

%% images with their descriptions
\NewDocumentEnvironment {illust} { s o m }
{
	\group_begin:
	\IfNoValueTF{#2}
	{
		\dim_set:Nn \l_tmpa_dim {.5\textwidth}
		\dim_set:Nn \l_tmpb_dim {.5\textwidth}
	}
	{
		\dim_set:Nn \l_tmpa_dim {#2\textwidth}
		\dim_set:Nn \l_tmpb_dim {\textwidth}
		\dim_add:Nn \l_tmpb_dim {-\l_tmpa_dim}
	}
	\hspace*{-.5em}
	\begin{minipage}{\l_tmpa_dim}
		\vspace*{1ex}
		\IfBooleanTF {#1}
		{ 
			\begin{rulebox}
				\includegraphics[width=.95\linewidth]{#3} 
			\end{rulebox}
		}
		{ 
			\includegraphics[width=.95\linewidth]{#3} 
		}
	\end{minipage}\hspace{.5em}
	\begin{minipage}{\l_tmpb_dim}
		\narrative
}{
	\end{minipage}
	\group_end:
}

\NewDocumentEnvironment {excerpt} { } 
{
	\setbeamercolor{background~canvas}{bg=}
}{}

\graphicspath{{images/}{../images/}}

\IfSlide{
	\NewDocumentCommand \biblio { s m }
	{
		\smallskip
		\begin{flushright}
			\IfBooleanF{#1}
			{
				\rule{.3\linewidth}{.25pt}\\
			}
			\footnotesize #2
		\end{flushright}
	}
}[
	\NewDocumentCommand \biblio {s m} {\mbox{}\newline---\thinspace #2}
]

%% frame title
\setbeamertemplate{frametitle~continuation}[from~second]

\IfSlide{
	\IfHangul{		
		\renewcommand\insertcontinuationtext{{\scriptsize(계속)}}		
	}[
		\renewcommand\insertcontinuationtext{{\scriptsize(cont.)}}
	]
}

%% blocks
\newcommand\sepbelow{\parbox{0pt}{\rule{0pt}{4ex}}}
\setbeamerfont{block~title}{size=\normalsize\sepbelow}
\setbeamerfont{block~body}{size=\narrative}
\setbeamerfont{block~body~example}{size=\narrative}
\setbeamerfont{block~body~alerted}{size=\narrative}

\definecolor{backgray}{gray}{0.9}
\newtcolorbox{shadebox}[1][]{
	before~skip=.5\baselineskip, after~skip=.5\baselineskip,	
	boxrule=0.25pt, colframe=gray, colback=backgray, arc=0.5ex,
	boxsep=0.25ex, top=0.75ex, bottom=0.75ex, left=0.5em, right=0.5em,
	titlerule=0.75pt, toptitle=0.25ex, bottomtitle=0.5ex,
	title=#1
}

%% lists
\setbeamertemplate{enumerate~subitem}{\Alph{enumii}.}
%%\defbeamertemplate{description~item}{align~left}{\insertdescriptionitem\hfill}
\setbeamertemplate{description~item}{\insertdescriptionitem\hfill}

% Use LuaLaTeX
\sys_if_engine_luatex:TF
{
	\setsansfallbackfont{HCR~Dotum}
}{
	\newfontfamily\fallbackhanjafont{HCR~Dotum}
}
\newfontfamily\sbfamily{HANDotum.ttf}[BoldFont=HANDotumB.ttf]
\NewDocumentCommand \foreign { s o m }
{
	\group_begin:
	\IfValueTF{#2}
	{
		\fontspec{#2}
	}{
		\sbfamily
	}
	\IfBooleanTF { #1 }{ \char"#3 }{ #3 }
	\group_end:
}

\keys_define:nn { annotate }
{
	opening		.tl_set:N = \l_annotate_opening_tl,
	closing		.tl_set:N = \l_annotate_closing_tl,
	font		.tl_set:N = \l_annotate_font_tl,
	color		.tl_set:N = \l_annotate_color_tl,
	raise 		.tl_set:N = \l_annotate_raise_tl,
}

\NewDocumentCommand \AnnotateSetup { m }
{
	\keys_set:nn { annotate } {#1}
}

\AnnotateSetup{
	font=\scriptsize,
	color=gray,
	opening={},
	closing={},
	raise=.75ex
}

\NewDocumentCommand \annotate { O{} m }
{
	\AnnotateSetup{#1}
	\raisebox{\l_annotate_raise_tl}{
		\color{\l_annotate_color_tl}
		\l_annotate_font_tl
		\l_annotate_opening_tl #2 \l_annotate_closing_tl
	}
}
\cs_set_eq:NN \anota \annotate

\tl_new:N \l_exam_style
\tl_set:Nn \l_exam_style { \color{gray} }
\NewDocumentCommand \exam {s m} 
{
	\IfBooleanTF{#1}
	{
		\par
		\group_begin:
			\l_exam_style \foreign*{270D}~#2
		\group_end:
	}
	{
		\par
		\group_begin:
			\l_exam_style #2
		\group_end:
	}
}

%% tables
\NewExpandableDocumentCommand\TableHeadFont{}{\rowfont{\bfseries}}
\NewDocumentCommand \cellhead {m}
{
	\group_begin:
		\small\bfseries #1
	\group_end:
}

%% overlay
\int_new:N \l_expose_int
\definecolor{obscuregray}{gray}{0.95}
\newcommand\UnexposedColor{obscuregray}
\newcommand\EmphColor{Brown}
\DeclareExpandableDocumentCommand \expose { s t^ o m }
{
	\IfBooleanTF { #1 }
	{ 
		\int_set:Nn \l_expose_int { 2 } 
	}{
		\IfValueTF { #3 } 
		{ 
			\int_set:Nn \l_expose_int {#3} 
		}{
			\int_incr:N \l_expose_int 
		}
	}
	
	\tl_set:Nn \l_tmpa_tl { \int_use:N \l_expose_int }

	\alt<\l_tmpa_tl->
	{
		\IfBooleanTF { #2 }
		{
			\textcolor{ \EmphColor }{ #4 }
		}{
			#4
		}
	}{
		\textcolor{ \UnexposedColor }{ #4 }
	}
}

\NewDocumentCommand \hint { s m }
{
	\IfBooleanTF { #1 }
	{
		\begin{flushright}
		\color{lightgray}\tiny #2
		\end{flushright}
	}{
		\hfill \textcolor{lightgray}{\tiny #2}
	}
}

\NewDocumentCommand \setverbatimfont { m }
{
	\def\verbatim@font{#1}	
}

\NewDocumentCommand \email { m }
{
    \href{mailto:#1}{\nolinkurl{#1}}
}

\ExplSyntaxOff

\setverbatimfont{\ttfamily\footnotesize}
\setbeamercolor{alerted text}{fg=Brown}
\TabPositions{ 0pt, 0.25\linewidth, 0.5\linewidth, 0.75\linewidth }

\AtBeginDocument{
	\justified
	\linespread{1.2}
}