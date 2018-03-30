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
\RequirePackage{fontspec, xunicode, xltxtra}
\RequirePackage{bookmark}
\RequirePackage{etoolbox}
\RequirePackage{environ}
\RequirePackage{graphicx}
\RequirePackage{tikz}
\RequirePackage{tcolorbox}
\RequirePackage{tabu}
\RequirePackage{pdfpages}
\includepdfset{nup=2x1}
%%\RequirePackage[yyyymmdd]{datetime}
%%\renewcommand\dateseparator{-}

%% fonts
\setsansfont{TeX Gyre Heros}
\setmonofont{Latin Modern Mono}
%\setmonofont{TeX Gyre Cursor}

\IfHangul{
	\RequirePackage[hangul]{kotex}
	\ifXeTeX
		\xetexkofontregime[cjksymbols=hangul]{latin}		
	\fi
	\setmainhangulfont{KoPubBatang}[Ligatures=TeX,Scale=MatchUppercase,UprightFont={*PL},BoldFont={*PM}]
	\setsanshangulfont{KoPubDotum}[Ligatures=TeX,Scale=MatchUppercase,UprightFont={*PL},BoldFont={*PM}]
	\setmonohangulfont{KoPubDotum}[Scale=MatchLowercase,UprightFont={*PL},BoldFont={*PM}]
}

% Bookmark frame titles
% \apptocmd{\beamer@@frametitle}{\bookmark[page=\the\c@page,level=3]{#1}}%
% {\message{** patching of \string\beamer@@frametitle succeeded **}}%
% {\message{** patching of \string\beamer@@frametitle failed **}}%

\newcommand\justified{\rightskip\z@skip\leftskip\z@skip}

\ExplSyntaxOn
\NewDocumentCommand \narrative {s}
{
	\IfBooleanTF{#1} {\normalsize} {\small}
	\justified
}

%% division
\NewDocumentCommand \Section {s m}
{
	\section{#2}
	\IfBooleanT{#1}
	{
		\begin{frame}[standout]
		#2
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
}
[
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
	}
	{
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
}
{
	\end{minipage}
	\group_end:
}

\NewDocumentEnvironment {excerpt} { } 
{
	\setbeamercolor{background~canvas}{bg=}
}{}

\graphicspath{{images/}{../images/}}

\IfSlide{
	\NewDocumentCommand \biblio {s m}
	{
		\group_begin:
		\IfBooleanTF{#1}
		{
			\setlength\parskip{0ex}
		}{
			\setlength\parskip{-1ex}
		}		
		\begin{flushright}
			\IfBooleanF{#1}
			{
				\rule{.3\linewidth}{.25pt}\\
			}
			\footnotesize #2
		\end{flushright}
		\group_end:
	}
}[
	\NewDocumentCommand \biblio {s m} {---\thinspace #2}
]

%% frame title
\setbeamertemplate{frametitle~continuation}[from~second]

\IfHangul{		
	\renewcommand\insertcontinuationtext{{\scriptsize(계속)}}		
}[
	\renewcommand\insertcontinuationtext{{\scriptsize(cont.)}}
]

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

%% characters & letters
\NewDocumentCommand \SetForeignFonts { m m }
{
	\newfontfamily\foreignrmfamily{#1}
	\newfontfamily\foreignsffamily{#2}
}

\SetForeignFonts{HCR Batang}{HCR Dotum}

\tl_new:N \WithHangul
\IfHangul{ 
	\tl_set:Nn \WithHangul {\disablekoreanfonts} 
}

\NewDocumentCommand \foreign {s o m}
{
	\group_begin:
		\WithHangul
		\ifx\f@family\rmdefault
			\IfNoValueTF {#2} {\foreignrmfamily} {\fontspec{#2}}
		\else
			\IfNoValueTF {#2} {\foreignsffamily} {\fontspec{#2}}
		\fi
		\IfBooleanTF {#1} {\char"#3} {#3}
	\group_end:
}

\NewDocumentCommand \smiley {} 
{ 
	{\color{red}\bfseries\foreign*{263A}~} 
}

\NewDocumentCommand \frowny {} 
{ 
	{\color{blue}\bfseries\foreign*{2639}~}
}

\NewDocumentCommand \prefer {s} 
{ 
	\IfBooleanTF{#1}
		{ \smiley }
		{ \item[\smiley] } 
}

\NewDocumentCommand \avoid {s} 
{ 
	\IfBooleanTF{#1}
		{ \frowny }
		{ \item[\frowny] } 
}

\NewDocumentCommand \Vdots { } 
{ 
	\foreign*{22EE}
}

\NewDocumentCommand \changeto { } 
{ 
	\textbf{\large\textrightarrow}~ 
}

\NewDocumentCommand \ui {m} 
{ 
	\textcolor{darkgray}{\textbf{#1}} 
}

\NewDocumentCommand \opt {s m}
{
	\IfBooleanTF{#1}
		{\small\foreign*{2611}~#2\quad}%% ballot box with check
		{\small\foreign*{2610}~#2\quad}%% ballot box
}

\NewDocumentCommand \oitem {s}
{
	\IfBooleanTF{#1}
		{\item[\foreign*{2611}]}
		{\item[\foreign*{2610}]}
}

\keys_define:nn { annotate }
{
	opening		.tl_set:N = \l_annotate_opening,
	closing		.tl_set:N = \l_annotate_closing,
	font		.tl_set:N = \l_annotate_font,
	color		.tl_set:N = \l_annotate_color,
	%%star		.tl_set:N = \l_annotate_star,
}

\NewDocumentCommand \AnnotateSetup { m }
{
	\keys_set:nn { annotate } {#1}
}

\AnnotateSetup{
	font=\footnotesize,
	color=darkgray,
	opening=(,
	closing=),
}


\NewDocumentCommand \annotate { O{} m }
{
	\AnnotateSetup{#1}
	\group_begin:		
		\color{\l_annotate_color}
		\l_annotate_font
		\l_annotate_opening #2 \l_annotate_closing
	\group_end:
}

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
\taburowcolors{white .. lightgray}
\NewExpandableDocumentCommand\TableHeadFont{}{\rowfont{\bfseries}}
\NewDocumentCommand \cellhead {m}
{
	\group_begin:
		\small\bfseries #1
	\group_end:
}

%% overlay
\int_new:N \l_expose_int
\DeclareExpandableDocumentCommand \expose { s o m }
{
	\IfBooleanT {#1} { \int_zero:N \l_expose_int }
	\int_incr:N \l_expose_int 
	\IfValueT {#2} { \int_set:Nn \l_expose_int {#2} }
	\tl_set:Nn \l_tmpa_tl { \int_use:N \l_expose_int }
	\alt<\l_tmpa_tl->{#3}{\textcolor{lightgray}{#3}}
}

\NewDocumentCommand \setverbatimfont { m }
{
	\def\verbatim@font{#1}	
}
\ExplSyntaxOff
\setverbatimfont{\ttfamily\footnotesize}

\setbeamercolor{alerted text}{fg=Brown}

\AtBeginDocument{
	\justified
	\linespread{1.2}
}
\endinput