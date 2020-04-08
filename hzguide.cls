% Variables beginning with "Hz" or "hz" are intended to be effective through the entire document.

% Obey these naming rules for command macros, environment macros, variables, and parameter keys.
% I. Minimize use of acronyms and abbreviations 
% II. For those of user interface level (\NewDocumentCommand):
%     1) As for single words, do not capitalize.
%     2) As for closed compound words, use camelcase.
%        If partly abbreviated, do not capitalize.
%     3) When an environment is made from a command only in order to take paragraphs, capitalize the environment's name if it is a single word.
% III. For those of programmer interface level (\cs_new:Npn):
%     1) Use only lowercase since underscores can be used.
%     2) It is allowed to omit prefixes 'g_' and 'l_' and suffixes such as '_bool' and '_tl' 
%        when those are intended to be limitedly used with specific purposes at user interface level, such as cover design.
% IV. For those of designer interface level:
%     Follow clause II. However, it is allowed to use lowercase with compound words.

\ProvidesClass{hzguide}[2018/08/13]

\LoadClassWithOptions{memoir}

%\RequirePackage{iftex}
\RequirePackage{expl3,xparse,l3keys2e}
\RequirePackage{environ}
\RequirePackage{fontspec}
\RequirePackage{ragged2e}
\RequirePackage{xspace}
\RequirePackage[shortlabels]{enumitem}
\RequirePackage{tabto}
\RequirePackage[normalem]{ulem}
\RequirePackage[svgnames,x11names,dvipsnames,hyperref,table]{xcolor}
\RequirePackage{graphicx}
\RequirePackage{eso-pic}
\RequirePackage{tikz, tikzpagenodes}
\RequirePackage{tcolorbox}
\RequirePackage{tabularx, longtable, multirow}
\RequirePackage[obeyspaces, spaces]{url} 
    %\path{file path}
    % when using \path and, if necessary, redefine \flushleft as below to avoid spaces above and below it.
    %\def\flushleft{\setlength\topsep{0pt}\trivlist \raggedright\item\relax}
\RequirePackage{hyperref}
\RequirePackage{bookmark}
\RequirePackage{calc} % to allow arithmetic expressions for \setlength 
\RequirePackage{etoolbox}

% ^^^^ac00 
% ^^^^^^020000  
% \char44032 
% \char"AC00 
% \char'126000 
% \char`가 
% \char`^^^^ac00

% if necessary, \let\cleardoublepage\relax to inhibit \mainmatter from producing a blank page

% \begin{minipage}[pos][height][contentpos]{width} text \end{minipage}
% \parbox[pos][height][contentpos]{width}{text}

% class options * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

\ExplSyntaxOn
\keys_define:nn { HzGuide }
{
    english     .code:n = { \LanguageSetup{ english } },
    korean      .code:n = { \LanguageSetup{ korean } },
    language    .code:n = { \LanguageSetup{ #1 } },
    styleset    .tl_set:N = \g_style_set_tl,
    doctype     .code:n = { \SetDocType{#1} },
    Noto        .bool_set:N = \g_Noto_bool,
    smallerfont .bool_set:N = \g_smallerfont_bool,
    minted    	.bool_set:N = \g_minted_bool,
    pairquote   .bool_set:N = \g_pairquote_bool,
    uprightmath .bool_set:N = \g_upright_math_bool,
}

\tl_new:N \HzLang
\bool_new:N \g_CJK_bool
\bool_gset_false:N \g_CJK_bool

\NewDocumentCommand \LanguageSetup {m}
{
    \str_case:nn {#1}
    {
        {english}     { \tl_set:Nn \HzLang {eng} } % 0  ENGLISH
        {chinese}     { \tl_set:Nn \HzLang {chi} } % 1  中文
        {czech}       { \tl_set:Nn \HzLang {cze} } % 2  ČEŠTINA
        {danish}      { \tl_set:Nn \HzLang {dan} } % 3  DANSK
        {dutch}       { \tl_set:Nn \HzLang {dut} } % 4  NEDERLANDS
        {finnish}     { \tl_set:Nn \HzLang {fin} } % 5  SUOMI
        {french}      { \tl_set:Nn \HzLang {fre} } % 6  FRANÇAIS
        {german}      { \tl_set:Nn \HzLang {ger} } % 7  DEUTSCH
        {italian}     { \tl_set:Nn \HzLang {ita} } % 8  ITALIANO
        {japanese}    { \tl_set:Nn \HzLang {jap} } % 9  日本語
        {korean}      { \tl_set:Nn \HzLang {kor} } % 10 한국어
        {norwegian}   { \tl_set:Nn \HzLang {nor} } % 11 NORSK
        {polish}      { \tl_set:Nn \HzLang {pol} } % 12 POLSKI
        {portuguese}  { \tl_set:Nn \HzLang {por} } % 13 PORTUGUÊS
        {russian}     { \tl_set:Nn \HzLang {rus} } % 14 РУССКИЙ ЯЗЫК
        {slovakian}   { \tl_set:Nn \HzLang {slo} } % 15 SLOVENČINA
        {spanish}     { \tl_set:Nn \HzLang {spa} } % 16 ESPAÑOL
        {swedish}     { \tl_set:Nn \HzLang {swe} } % 17 SVENSKA
        {turkish}     { \tl_set:Nn \HzLang {tur} } % 18 TÜRKÇE
        {TC}          { \tl_set:Nn \HzLang {TC} } % traditional chinese
    }
}

% \BookmarkLanguage{ENGLISH}[0]
\NewDocumentCommand \BookmarkLanguage { m O{-1} }
{
    \bookmark[level=#2, page=1]{#1}	
}

\NewDocumentCommand \IfLang { m +m o }
{
    \str_if_eq:VnTF \HzLang {#1}
    { 
        #2 
    }{ 
        \IfValueT {#3} {#3} 
    }
}

% if this document's type is ...
\clist_new:N \g_doc_type
\NewDocumentCommand \SetDocType { m }
{
    \clist_gput_right:Nn \g_doc_type { #1 }
}


\cs_new:Npn \doc_type_check:n #1
{
    \bool_gset_false:N \g_tmpa_bool
    \clist_map_inline:Nn \g_doc_type
    {
        \str_if_eq:nnT { ##1 }{ #1 }
        {
            \bool_gset_true:N \g_tmpa_bool 
        }
    }
}

\NewDocumentCommand \IfDocType { m +m o }
{
    \doc_type_check:n { #1 }
    \bool_if:NTF \g_tmpa_bool
    {
        #2 
    }{ 
        \IfValueT { #3 }{ #3 } 
    }
}

\NewDocumentCommand \IfNotDocType { m +m o }
{
    \doc_type_check:n #1
    \bool_if:NTF \g_tmpa_bool
    { 
        \IfValueT { #3 }{ #3 } 
    }{ 
        #2 
    }
}

\NewEnviron{IfDoc}[1]
{
    \IfDocType{ #1 }{ \BODY }
}
\NewEnviron{IfNotDoc}[1]
{
    \IfNotDocType{ #1 }{ \BODY }
}


\NewDocumentCommand \ClassSetup { m }
{
    \keys_set:nn { HzGuide }{ #1 }
}

% default class options
\ClassSetup
{
    %minted = false,    
    language = korean,
    %pairquote = false,
}

\ProcessKeysOptions{ HzGuide }
\tcbuselibrary{listings}
\hypersetup{pdfencoding=auto, bookmarksnumbered=true, linktoc=all, pdfauthor={hzguide.cls}} 


\bool_if:NT \g_smallerfont_bool %\documentclass[9pt, smallerfont]
{
    \cs_set_eq:NN \HUGE \Huge %17pt
    \cs_set_eq:NN \Huge \huge %14pt
    \cs_set_eq:NN \huge \LARGE %12pt
    \cs_set_eq:NN \LARGE \Large %11pt
    \cs_set_eq:NN \Large \large %10pt
    \cs_set_eq:NN \large \normalsize %9pt
    \cs_set_eq:NN \normalsize \small %8pt
    \cs_set_eq:NN \small \footnotesize %7pt
    \cs_set_eq:NN \footnotesize \scriptsize %6pt
    \cs_set_eq:NN \scriptsize \tiny  %5pt
    \cs_set_eq:NN \tiny \miniscule %4pt
}

\bool_if:NT \g_minted_bool
{
    \RequirePackage{minted}
}

\bool_if:NT \g_pairquote_bool
{
    \RequirePackage{csquotes}
    \MakeOuterQuote{"}
}

\bool_if:NT \g_upright_math_bool
{
    \RequirePackage{unicode-math}
    \setmathfont[math-style=upright]{TeX~Gyre~Pagella}
}

\cs_set_eq:NN \Sup \textsuperscript
\cs_set_eq:NN \Sub \textsubscript

\IfLang{chi}
{
    \bool_gset_true:N \g_CJK_bool
    \newcommand\prenum{第}
}

\IfLang{jap}
{
    \bool_gset_true:N \g_CJK_bool
    \newcommand\prenum{第}
}

\IfLang{kor}
{
    \bool_gset_true:N \g_CJK_bool
    \newcommand\prenum{제}
	\renewcommand*{\printpartname}{\partnamefont\prenum}
	\renewcommand*{\printpartnum}{\partnumfont\thepart\space\partnamefont\partname}
	\renewcommand*{\partnamenum}{\space}
}

%\ExplSyntaxOff

% language settings -----------------------------------------------------------

\IfLang{chi}
{
    \RequirePackage{xeCJK}
    \setCJKmainfont{Noto Serif CJK SC}
    \setCJKsansfont{Noto Sans CJK SC}
    \punctstyle{fullwidth}
    \renewcommand*{\abstractname}{摘要}
    \renewcommand*{\contentsname}{目录}
    \renewcommand*{\listfigurename}{插图目录}
    \renewcommand*{\listtablename}{表格目录}
    \renewcommand*{\partname}{部分}
    \renewcommand*{\partrefname}{部分}
    \renewcommand*{\chaptername}{章}
    \renewcommand*{\chapterrefname}{章}
    \renewcommand*{\appendixname}{附录}
    \renewcommand*{\bibname}{参考文献}
    \renewcommand*{\indexname}{索引}
    \renewcommand*{\figurename}{图}
    \renewcommand*{\figurerefname}{图}
    \renewcommand*{\tablename}{表}
    \renewcommand*{\tablerefname}{表}
    \renewcommand*{\Cref}[1]{\ref{#1}\chapterrefname}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=危险, %危險,
            warning=警告,
            caution=注意事项, %小心,
            notice=注意,
            note=注
        }
    \LineImageSetup{raise=0pt}
    }
}

\IfLang{TC}
{
    \RequirePackage{xeCJK}
    \setCJKmainfont{Noto Serif CJK TC}
    \setCJKsansfont{Noto Sans CJK TC}
    \punctstyle{fullwidth}
    \renewcommand*{\abstractname}{要約}
    \renewcommand*{\contentsname}{目錄}
    \renewcommand*{\listfigurename}{圖目錄}
    \renewcommand*{\listtablename}{表目錄}
    \renewcommand*{\chaptername}{章}
    \renewcommand*{\chapterrefname}{章}
    \renewcommand*{\appendixname}{附錄}
    \renewcommand*{\bibname}{参考文献}
    \renewcommand*{\indexname}{索引}
    \renewcommand*{\figurename}{圖}
    \renewcommand*{\figurerefname}{圖}
    \renewcommand*{\tablename}{表}
    \renewcommand*{\tablerefname}{表}
    \renewcommand*{\Cref}[1]{\ref{#1}\chapterrefname}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=危险,
            warning=警告,
            caution=小心,
            notice=注意,
            note=注
        }
    \LineImageSetup{raise=0pt}
    }
}

\IfLang{cze}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{czech}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=NEBEZPEČÍ,
            warning=VAROVÁNÍ,
            caution=UPOZORNĚNÍ,
            notice=UPOZORNĚNÍ,
            note=POZNÁMKA
        }
    }
}

\IfLang{dan}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{danish}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=FARE,
            warning=ADVARSEL,
            caution=FORSIGTIG,
            notice=BEMÆRK,
            note=NOTE
        }
    }
}

\IfLang{dut}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{dutch}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=GEVAAR,
            warning=WAARSCHUWING,
            caution={LET OP},
            notice=KENNISGEVING,
            note=OPMERKING
        }
    }
}

\IfLang{fin}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{finnish}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=VAARA,
            warning=VAROITUS,
            caution=HUOMIO,
            notice=HUOMAUTUS,
            note=ILMOITUS
        }
    }
}


\IfLang{fre}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{french}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=DANGER,
            warning=AVERTISSEMENT,
            caution=ATTENTION,
            notice=AVIS,
            note=REMARQUE
        }
    }
}

\IfLang{ger}
{
    \RequirePackage{polyglossia}
    %\renewcommand*{\sectionrefname}{Abschnitt~}
    \setmainlanguage[variant=german, spelling=new, latesthyphen=true]{german}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=GEFAHR,
            warning=WARNUNG,
            caution=VORSICHT,
            notice=HINWEIS, %BEACHTEN
            note=ANMERKUNG,
        }
    }
}

\IfLang{ita}
{
    %\RequirePackage[none]{hyphenat}
    \RequirePackage{polyglossia}
    \setmainlanguage{italian}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=PERICOLO,
            warning=AVVERTENZA,
            caution=ATTENZIONE,
            notice=AVVISO,
            note=NOTA
        }
    }
}

\IfLang{jap}
{
    \RequirePackage{xeCJK}
    \setCJKmainfont{Noto Serif CJK JP}
    \setCJKsansfont{Noto Sans CJK JP}
    \punctstyle{fullwidth}
    \renewcommand*{\abstractname}{概要}
    \renewcommand*{\contentsname}{目次}
    \renewcommand*{\listfigurename}{図目次}
    \renewcommand*{\listtablename}{表目次}
    \renewcommand*{\partname}{部}
    \renewcommand*{\partrefname}{部}
    \renewcommand*{\chaptername}{章}
    \renewcommand*{\chapterrefname}{章}
    \renewcommand*{\appendixname}{付録}
    \renewcommand*{\bibname}{参考文献}
    \renewcommand*{\indexname}{索引}
    \renewcommand*{\figurename}{図}
    \renewcommand*{\figurerefname}{図}
    \renewcommand*{\tablename}{表}
    \renewcommand*{\tablerefname}{表}
    \renewcommand*{\Cref}[1]{\ref{#1}\,\chapterrefname}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=危険,
            warning=警告,
            caution=注意,
            notice=注記, % 注意事項
            note=参考 % 注意
        }
    \LineImageSetup{raise=0pt}
    }
}

\IfLang{kor}
{
	%\XeTeXcharclass"201C = \XKlatinopening
    %\XeTeXcharclass"201D = \XKlatinclosing	
    % how to use different fonts for the same font command
    % \newhangulfontfamily\gungseo{GungSeo}[SlantedFont=*]
    % \newhangulfontfamily\pilgi{Pilgi}[ItalicFont=*]
    % \edef\slshape{\unexpanded\expandafter{\slshape\gungseo}}
    % \edef\itshape{\unexpanded\expandafter{\itshape\pilgi}}
    \sys_if_engine_xetex:TF
	{
        \RequirePackage[hangul]{xetexko}        
    }{	
        \sys_if_engine_luatex:T
		{
            \RequirePackage[hangul]{luatexko}
        }
    }
    \bool_if:NT \g_Noto_bool
    {
        \setmainhangulfont{Noto~Serif~CJK~KR}[BoldFont={*~SemiBold}]
        \setsanshangulfont{Noto~Sans~CJK~KR}[BoldFont={*~Medium}]
    }
    \AtBeginDocument{
        \renewcommand*{\contentsname}{차례}
        \AdmonitionSetup {
            danger=위험,
            warning=경고,
            caution=주의,
            notice=주의, %알림
            note=참고            
        }
        \ProblemSetup{name={}}
    }
}

\IfLang{nor}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{norsk}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=FARE,
            warning=ADVARSEL,
            caution=FORSIKTIG,
            notice=VARSEL,
            note=MERK
        }
    }
}

\IfLang{pol}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{polish}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=NIEBEZPIECZEŃSTWO,
            warning=OSTRZEŻENIE,
            caution=PRZESTROGA,
            notice=UWAGA,
            note=INFORMACJA
        }
    }
}

\IfLang{por} % Brazilian
{
    \RequirePackage{polyglossia}
    \setmainlanguage{portuges}
    \setotherlanguage{english}
    \renewcommand*{\contentsname}{Índice}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=PERIGO,
            warning=ATENÇÃO,
            caution=CUIDADO,
            notice=AVISO,
            note=NOTA
        }
    }
}

\IfLang{rus}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{russian}
    \setotherlanguage{english}
    \@ifpackageloaded{csquotes}{
        \setquotestyle{russian}
    }{}
    \newfontfamily\cyrillicfont{CMU Serif}[Script=Cyrillic]
    \newfontfamily\cyrillicfontsf{CMU Sans Serif}[Script=Cyrillic]
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=ОПАСНО,
            warning=ПРЕДОСТЕРЕЖЕНИЕ,
            caution=ПРЕДУПРЕЖДЕНИЕ,
            notice=ПОМЕТКА,
            note=ПРИМЕЧАНИЕ
        }
    }
}

\IfLang{slo}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{slovak}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=NEBEZPEČENSTVO,
            warning=VÝSTRAHA,
            caution=UPOZORNENIE,
            notice=POZNÁMKA,
            note=POZNÁMKA
        }
    }
}

\IfLang{spa} % Latin
{
    \RequirePackage{polyglossia}
    \setmainlanguage{spanish}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=PELIGRO,
            warning=ADVERTENCIA,
            caution=PRECAUCIÓN,
            notice=AVISO,
            note=NOTA
        }
    }
}

\IfLang{swe}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{swedish}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=FARA,
            warning=VARNING,
            caution=FÖRSIKTIGT,
            notice=UPPMÄRKSAMMA,
            note=OBSERVERA
        }
    }
}

\IfLang{tur}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{turkish}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=TEHLİKE,
            warning=UYARI,
            caution=DİKKAT,
            notice=BİLDİRİM,
            note=NOT
        }
    }
}

%\ExplSyntaxOn

% class utilities to customize styles * * * * * * * * * * * * * * * * * * * * *

\NewDocumentCommand \IfDefined { m m O{} }
{
    \cs_if_exist:NTF #1 { #2 } { #3 }
}

\NewDocumentCommand \IfUndefinedTF { m m O{} }
{
    \cs_if_exist:NFT #1 { #2 } { #3 }
}

\box_new:N \l_tmpc_box
\cs_new:Npn \dim_set_towidth:Nn #1 #2
{
    \exp_args:NNo \hbox_set:Nn \l_tmpc_box { #2 }
    \dim_set:Nn #1 { \box_wd:N \l_tmpc_box }
}
\cs_new:Npn \dim_set_toheight:Nn #1 #2
{
    \exp_args:NNo \hbox_set:Nn \l_tmpc_box { #2 }
    \dim_set:Nn #1 { \box_ht:N \l_tmpc_box + \box_dp:N \l_tmpc_box }
}

% To enable default configuration, especially for Sphinx and Jupyter ------------------------------
% \IfNoAdhoc{layout}{\LayoutSetup{paper=A4,column=...}}
% \IfNoAdhoc{heading}{\HeadingSetup{...}}
\keys_define:nn { adhoc }
{
    layout      .bool_set:N = \g_adhoc_layout_bool,
    heading     .bool_set:N = \g_adhoc_heading_bool,
}

\NewDocumentCommand \AdhocSetup { m }
{
    \keys_set:nn { adhoc }{ #1 }
}

\AdhocSetup{layout=false, heading=false}

\NewDocumentCommand \IfNoAdhoc { m m }
{
    \str_case:nn { #1 }
    {
        { layout }  { \bool_if:NF \g_adhoc_layout_bool {#2} }
        { heading } { \bool_if:NF \g_adhoc_heading_bool {#2} }
    }
}

% covers ----------------------------------------------------------------------
\keys_define:nn { cover }
{
    TopSkip             .skip_set:N = \cover_top_skip,
    FrontLogoImage      .tl_set:N = \cover_image_logo_front,	
    BackLogoImage       .tl_set:N = \cover_image_logo_back,	
    ProductImage        .tl_set:N = \cover_image_product,
    FrontImage     		.tl_set:N = \cover_image_background_front,
    BackImage     		.tl_set:N = \cover_image_background_back,
    title			    .tl_set:N = \cover_title,
    subtitle            .tl_set:N = \cover_subtitle,
    TitleAlign			.tl_set:N = \cover_title_align,
    DocumentType        .tl_set:N = \cover_doc_type,
    PubYear				.tl_set:N = \cover_pub_year,
    revision		    .tl_set:N = \cover_revision,
    note			    .tl_set:N = \cover_note,
    manufacturer	    .tl_set:N = \cover_manufacturer,
    address             .tl_set:N = \cover_manufacturer_address,
    AfterFront		    .tl_set:N = \cover_after_front,
    BeforeBack		    .tl_set:N = \cover_before_back,
    FontI			    .tl_set:N = \cover_font_i,
    FontII              .tl_set:N = \cover_font_ii,
    FontSizeI			.tl_set:N = \cover_font_size_i,
    FontSizeII			.tl_set:N = \cover_font_size_ii,
    FontSizeIII		    .tl_set:N = \cover_font_size_iii,
    FontSizeIV			.tl_set:N = \cover_font_size_iv,
	BlankFront			.bool_set:N = \cover_blank_front_bool,
    BlankBack			.bool_set:N = \cover_blank_back_bool,
    hook                .tl_set:N = \cover_hook_tl,
}

\NewDocumentCommand \CoverSetup { m }
{
    \keys_set:nn { cover } { #1 }  
}

\tl_set:Nn \cover_pub_year { \int_to_arabic:n {\c_sys_year_int} }

\CoverSetup{
    TopSkip = .1\textheight,
    FontI = \sffamily\bfseries\color{darkgray},
    FontII = \sffamily\bfseries\color{darkgray},
    FontSizeI = \Huge,
    FontSizeII = \huge,
    FontSizeIII = \LARGE,
    FontSizeIV = \Large,
    TitleAlign = \raggedright,
    ProductImage = cover_image,
    AfterFront=\clearpage, %\cleartorecto,
    BeforeBack=\clearpage, %\cleartoverso,
	BlankFront=false,
	BlankBack=false
}

\NewDocumentCommand \CoverFontSize { m }
{
    \str_case:nn {#1}
    {
        { 1 }{ \cover_font_size_i }
        { 2 }{ \cover_font_size_ii }
        { 3 }{ \cover_font_size_iii }
        { 4 }{ \cover_font_size_iv }
    }
}

\NewDocumentCommand \FrontCover { }
{	
    \thispagestyle{empty}
    \cover_hook_tl
    \tl_if_empty:NF \cover_image_background_front 
    {
		\begin{tikzpicture}[remember~picture,overlay] 
			\node~at~(current~page.center) { \includegraphics{\cover_image_background_front} };
		\end{tikzpicture}
    }
	\bool_if:NTF \cover_blank_front_bool
	{
		\mbox{}
	}
	{
		\begin{IfVartwoEnlarge}		
			\setSpacing{1}
			\tl_if_empty:NF \cover_image_logo_front
			{
				\includegraphics[scale=\l_image_scale_tl]{\cover_image_logo_front}
			}
			\mbox{}\par\vspace{\cover_top_skip}
			\begin{minipage}{\linewidth}
					\cover_title_align\cover_font_i
					\CoverFontSize{1} \cover_title                    
					\par\medskip
					\CoverFontSize{2} \cover_subtitle
			\end{minipage}      
			\tl_if_empty:NF \cover_image_product
			{
				\par\vspace{1cm}
				\begin{center}
						\includegraphics[scale=\l_image_scale_tl]{\cover_image_product}
				\end{center}
			}
			\vfill
			\begin{flushright}
					\cover_font_ii
					\CoverFontSize{3} \cover_doc_type
					\par
				\CoverFontSize{4} \cover_pub_year \hspace{0.5em}|\hspace{0.5em} \cover_revision
				\end{flushright}        
		\end{IfVartwoEnlarge}
	}
    \cover_after_front
}

\NewDocumentCommand \BackCover { }
{
    \cover_before_back
    \thispagestyle{empty}	
    \cover_hook_tl
	\tl_if_empty:NF \cover_image_background_back
    {
		\begin{tikzpicture}[remember~picture,overlay]
			\node~at (current~page.center) { \includegraphics{\cover_image_background_back} };
		\end{tikzpicture}
    }
	\bool_if:NTF \cover_blank_back_bool
	{
		\mbox{}
	}{
		\begin{IfVartwoEnlarge}		
			\AtPageBottom
			\setSpacing{1}        
			\tl_if_empty:NTF \cover_image_logo_back
			{            
                \tl_if_empty:NF \cover_note
                {
                    \cover_note \\
                }
			}{
				\illustimage[valign=b, afterskip=1ex]{\cover_image_logo_back}{\cover_note} \\
			}        
			\noindent	\raisebox{-0.25ex}{\rule{\headwidth}{0.5pt}} \\
			© \space \cover_pub_year \space \cover_manufacturer \\ 
			\cover_manufacturer_address
		\end{IfVartwoEnlarge}
	}
}

% extra style set  ------------------------------------------------------------
\NewDocumentCommand \LoadStyleset {}
{
    \tl_if_empty:NF \g_style_set_tl
    {
        \input{ \g_style_set_tl }
    }
}

\NewDocumentCommand \styleinput { m }
{
    \IfFileExists{ ../#1 }{ \input{../#1} }{}
    \IfFileExists{ #1 }{ \input{#1} }{}
}

% commonly used content -------------------------------------------------------
\keys_define:nn { commonpath }
{
    root        .tl_set:N = \g_common_path_root,
    language    .code:n = { \LanguagePathSetup{#1} }
}

\NewDocumentCommand \CommonPathSetup { m }
{
    \keys_set:nn { commonpath } { #1 }
}

\tl_new:N \g_common_path_language
\NewDocumentCommand \LanguagePathSetup { s m }
{
    \IfBooleanTF {#1}
    {
        \tl_set:Nn \g_common_path_language { #2 }
    }{
        \tl_set:No  \g_common_path_language { \g_common_path_root #2/ }
    }
}

\CommonPathSetup{
    root = { ../../../Common/ },
    language = \HzLang
}

\NewDocumentCommand \commoninput { s m }
{
    \IfBooleanTF { #1 }
    {
        \input{\g_common_path_root #2}
    }
    {
        \input{\g_common_path_language #2}
    }
}

% editing  --------------------------------------------------------------------

\keys_define:nn { pending }
{
    before-color	.tl_set:N = \l_pending_beforecolor_tl,
    after-color		.tl_set:N = \l_pending_aftercolor_tl,
    font			.tl_set:N = \l_pending_font_tl,
    hide			.bool_set:N = \l_pending_hide_bool
}

\NewDocumentCommand \PendingSetup { m }
{
    \keys_set:nn { pending } { #1 }
}

\PendingSetup{
    before-color=purple,
    after-color=blue,
    font=\small,
    hide=false
}

\NewDocumentCommand \pending { +m }
{
    \bool_if:NF \l_pending_hide_bool
    {
        { \color{\l_pending_beforecolor_tl}\l_pending_font_tl #1 }
    }
}

\NewEnviron{Pending}{\pending{\BODY}}

\NewDocumentCommand \HidePending {}
{
    \bool_set_true:N \l_pending_hide_bool
}

\NewDocumentCommand \ShowPending {}
{
    \bool_set_false:N \l_pending_hide_bool
}

\newcounter{query}
\renewcommand\thequery{\arabic{query})}
\newlistof{listofqueries}{loq}{Queries}
\newlistentry{query}{loq}{0}
\setcounter{loqdepth}{1}
\renewcommand*\cftqueryafterpnum{\bigskip}

\NewDocumentCommand \query { +m o }
{
	\stepcounter{query}	
	\bool_if:NF \l_pending_hide_bool
    {
		\hangfrom{
			\textcolor{\l_pending_beforecolor_tl}{
				\l_pending_font_tl \thequery
			}
		}\space
		\textcolor{\l_pending_beforecolor_tl}{
				\l_pending_font_tl #1
		}
    }
    \IfValueTF {#2}
    { 
		\addcontentsline{loq}{query}{\thequery\enspace #2 } 
	}{ 
		\addcontentsline{loq}{query}{\thequery\enspace #1 } 
	}
}

\cs_set_eq:NN \orglistofqueries \listofqueries

\RenewDocumentCommand \listofqueries { s }
{
    \group_begin:
    \bool_if:NF \l_pending_hide_bool
        {
            %\color{\l_pending_beforecolor_tl}
            \IfBooleanTF {#1} {\orglistofqueries*} {\orglistofqueries}
        }
    \group_end:
}

% deleted: \change*{}
% added: \change{}
% changed: \change[before]{after}
\NewDocumentCommand \change { s o m }
{
    \bool_if:NTF \l_pending_hide_bool
    {
        \IfBooleanTF {#1} {\ignorespaces} {#3}
    }{        
        \IfBooleanTF {#1}
        {
            \textcolor{\l_pending_beforecolor_tl}{\sout{#3}}
        }{
            \IfValueTF {#2}
            {
                \textcolor{\l_pending_beforecolor_tl}{\sout{#2}}~
                \textcolor{\l_pending_aftercolor_tl}{#3}                
            }{                
                \textcolor{\l_pending_aftercolor_tl}{#3}
            }
        }
    }
}

\NewDocumentCommand \changeitem { m m }
{
	\change[#1]{#2}
}

\cs_set_eq:NN \HideChanges \HidePending
\cs_set_eq:NN \ShowChanges \ShowPending

% letters  --------------------------------------------------------------------

% \NewDocumentCommand \nil {}
% {
%     \rule{0pt}{0pt}
% }

\NewDocumentCommand \AtPageBottom { s }
{
    \mbox{}\vfill
    \IfBooleanTF{#1}{}{ \thispagestyle{empty} }
}

% alphanumeric segment display
\keys_define:nn { segment }
{
    scale     .tl_set:N = \l_segment_scale,
    raise     .tl_set:N = \l_segment_raise,
    space     .tl_set:N = \l_segment_space,
    wordspace .tl_set:N = \l_segment_wordspace,
    breakable .bool_set:N = \l_segment_break_bool
}

\NewDocumentCommand \SegmentSetup { m }
{
    \keys_set:nn { segment }{ #1 }
}

\SegmentSetup{
    scale=1,
    raise=-0.5pt,
    space=0.1pt,
    wordspace=0.5em,
    breakable=true
}

\cs_new:Npn \segment_include:n #1
{
    \hspace{\l_segment_space}
    \raisebox{\l_segment_raise}{ \includegraphics[scale=\l_segment_scale]{#1} }
    \hspace{\l_segment_space}
}

\cs_new:Npn \segment_parse:n #1
{
    \seq_set_split:Nnn \l_tempa_seq { ~ } { #1 }
    \seq_map_inline:Nn \l_tempa_seq
    {
        \mbox{
            \seq_set_split:Nnn \l_tempb_seq {}{ ##1 }
            \seq_map_inline:Nn \l_tempb_seq
            {
                \str_case:nnF { ####1 }
                {
                    { m }{ \segment_include:n {M_} }
                    { o }{ \segment_include:n {O_} }
                    { r }{ \segment_include:n {R_} }
                    { - }{ \segment_include:n {minus} }
                    { _ }{ \segment_include:n {space} }
                    { . }{ \segment_include:n {dot} }
                    { ? }{ \segment_include:n {QuestionMark} }
                }{ 
                    \segment_include:n {####1} 
                }
            }
        }
        \hspace{\l_segment_wordspace} %\c_space_token
    }
    \hspace{-\l_segment_wordspace}
}

\NewDocumentCommand \segment { s m }
{
    \bool_if:NTF \l_segment_break_bool
    {
        \IfBooleanTF {#1}
        { 
            \mbox{\segment_parse:n {#2}} 
        }{ 
            \segment_parse:n {#2} 
        }
    }{
        \IfBooleanTF {#1}
        { 
            \segment_parse:n {#2} 
        }{ 
            \mbox{\segment_parse:n {#2}} 
        }
    }
}

\NewDocumentCommand \segitem { m }
{
    \item[\segment{#1}]
}

% layout * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

\tl_new:N \g_layout_type
\dim_zero_new:N \vartwosecindent

\bool_new:N \g_column_vartwo_bool

\NewDocumentCommand \IfVartwo { m O{} }
{
    \bool_if:NTF \g_column_vartwo_bool   { #1 }  { #2 }
}

\NewDocumentEnvironment {IfVartwoEnlarge} { O{-\vartwosecindent} }
{
    \bool_if:NT \g_column_vartwo_bool
    {
        \begin{adjustwidth}{#1}{0pt}
    }
}{
    \bool_if:NT \g_column_vartwo_bool
    {
        \end{adjustwidth}
    }
}

%% paper configuration --------------------------------------------------------

% A4
\cs_new:Npn \layout_paper_configure:n #1
{
    \str_case:nn { #1 }
    {
        {A3}          { \layout_paper_aiii: }
        {A4}          { \layout_paper_aiv: }
        {B5}          { \layout_paper_bv: }
        {A5}          { \layout_paper_av: }
        {A5V}          { \layout_paper_avv: } % 신국판
        {letter}      { \layout_paper_letter: }
        {46D}          { \layout_paper_ivvid: } % 사륙배판 = JIS B5
        {slide}       { \layout_paper_slide: }
        {arbitrary}   { \layout_paper_arbitrary: }
    }
}

% A3
\cs_new:Nn \layout_paper_aiii:
{
    \dim_gset:Nn \stockwidth {353mm}
    \dim_gset:Nn \stockheight {500mm}
    \dim_gset:Nn \paperwidth {297mm}
    \dim_gset:Nn \paperheight {420mm}
    \dim_gset:Nn \ulmargin {38mm}
    \dim_gset:Nn \lrmargin {40mm}
    \dim_gset:Nn \vartwomargin {20mm}
}

% A4
\cs_new:Nn \layout_paper_aiv:
{
    \dim_gset:Nn \stockwidth {250mm}
    \dim_gset:Nn \stockheight {353mm}
    \dim_gset:Nn \paperwidth {210mm}
    \dim_gset:Nn \paperheight {297mm}
    \dim_gset:Nn \ulmargin {36mm} % textheight: 297 - 72 = 225 mm (= 140 * 1.6)
    \dim_gset:Nn \lrmargin {35mm} % textwidth: 140 mm (= 210 - 70)
    \dim_gset:Nn \vartwomargin {20mm} % textwidth: 130 mm
}

% B5
\cs_new:Nn \layout_paper_bv:
{
    \dim_gset:Nn \stockwidth {210mm}
    \dim_gset:Nn \stockheight {297mm}
    \dim_gset:Nn \paperwidth {176mm}
    \dim_gset:Nn \paperheight {250mm}
    \dim_gset:Nn \ulmargin {29mm} % textheight: 250 - 58 = 192 mm (= 120 * 1.6)
    \dim_gset:Nn \lrmargin {28mm} % textwidth: 120 mm (= 176 - 56)
    \dim_gset:Nn \vartwomargin {14mm} 
}

% A5
\cs_new:Nn \layout_paper_av:
{
    \dim_gset:Nn \stockwidth {176mm}
    \dim_gset:Nn \stockheight {250mm}
    \dim_gset:Nn \paperwidth {148mm}
    \dim_gset:Nn \paperheight {210mm}
    \dim_gset:Nn \lrmargin {19mm}
    \dim_gset:Nn \ulmargin {17mm}
    \dim_gset:Nn \vartwomargin {10mm}
}

% Letter
\cs_new:Nn \layout_paper_letter:
{
    \dim_gset:Nn \stockwidth {250mm}
    \dim_gset:Nn \stockheight {353mm}
    \dim_gset:Nn \paperwidth {8.5in} % 8.5 in = 215.9 mm
    \dim_gset:Nn \paperheight {11in} % 11 in = 279.4 mm
    \dim_gset:Nn \ulmargin {30mm}
    \dim_gset:Nn \lrmargin {40mm}
    \dim_gset:Nn \vartwomargin {20mm}
}

% 46D
\cs_new:Nn \layout_paper_ivvid:
{
    \dim_gset:Nn \stockwidth {210mm}
    \dim_gset:Nn \stockheight {297mm}
    \dim_gset:Nn \paperwidth {182mm}
    \dim_gset:Nn \paperheight {257mm}
	\dim_gset:Nn \ulmargin {28.5mm} % textheight: 257 - 57 = 200 mm
    \dim_gset:Nn \lrmargin {26mm} % textwidth: 130 mm (= 182 - 52)
    \dim_gset:Nn \vartwomargin {14mm}
}

% A5V
\cs_new:Nn \layout_paper_avv:
{
    \dim_gset:Nn \stockwidth {176mm}
    \dim_gset:Nn \stockheight {250mm}
    \dim_gset:Nn \paperwidth {152mm}
    \dim_gset:Nn \paperheight {225mm}
    \dim_gset:Nn \ulmargin {20mm} % textheight: 225 - 40 = 185 mm
    \dim_gset:Nn \lrmargin {21mm} % textwidth: 110 mm (= 152 - 52)
    \dim_gset:Nn \vartwomargin {10mm}
}

\cs_new:Nn \layout_paper_slide:
{
    \dim_gset:Nn \stockwidth {9in}
    \dim_gset:Nn \stockheight {6in}
    \dim_gset:Nn \paperwidth {9in}
    \dim_gset:Nn \paperheight {6in}
    \tl_gset:Nn \g_layout_type {slide}
}

\cs_new:Nn \layout_paper_arbitrary:
{
    \tl_gset:Nn \g_layout_type {arbitrary}
}

\cs_new:Npn \layout_column_configure:n #1
{
    \str_case:nnT { #1 }
    {
        { one } {
                \bool_gset_false:N \g_column_vartwo_bool
                \tl_gset:Nn \g_layout_type {common}
                \tl_gset:Nn \ulratio {1}
            }
        { vartwo } {
                \bool_gset_true:N \g_column_vartwo_bool
                \tl_gset:Nn \g_layout_type {vartwo}
                \tl_gset:Nn \ulratio {1}
            }
    }
}

% layout configutation --------------------------------------------------------

\cs_new:Nn \layout_column_one:
{
    \setulmarginsandblock{\ulmargin}{*}{\ulratio}
    \setheadfoot{0.33\ulmargin}{0.33\ulmargin}
    \setheaderspaces{*}{*}{0.5}  % headsep = 0.5 * headdrop
    \setlrmarginsandblock{\lrmargin}{\lrmargin}{*}
    \g_layout_hook
    \checkandfixthelayout
}

\cs_new:Nn \layout_column_vartwo:
{
    \setulmarginsandblock{\ulmargin}{*}{\ulratio}
    \setheadfoot{0.33\ulmargin}{0.33\ulmargin}
    \setheaderspaces{*}{*}{0.5}
    \setlrmarginsandblock{3\vartwomargin}{\vartwomargin}{*}
    \setmarginnotes{.25\vartwomargin}{1.75\vartwomargin}{1ex}
    \g_layout_hook
    \checkandfixthelayout
    \let\evensidemargin\oddsidemargin
    \IfVartwo{ \dim_set:Nn \g_protrude_dim { \marginparwidth } }
}

\cs_new:Nn \layout_slide:
{
    \setulmarginsandblock{10mm}{10mm}{*}
    \setlrmarginsandblock{15mm}{15mm}{*}
    \setheadfoot{0mm}{5mm}
    \setlength\headsep{0mm}
    \g_layout_hook
    \checkandfixthelayout
}

\cs_new:Nn \layout_arbitrary:
{
    \setulmarginsandblock{\ulmargin}{*}{\ulratio}
    \setlrmarginsandblock{\lrmargin}{\lrmargin}{*}
    \setheadfoot{0mm}{5mm}
    \setlength\headsep{0mm}
    \g_layout_hook
    \checkandfixthelayout
}

% pagestyle -------------------------------------------------------------------
\tl_new:N \hffont
\tl_set:Nn \hffont {\rmfamily\small}

\keys_define:nn { pagestyle }
{
    font            .tl_gset:N =     \hffont,
    headleft        .code:n =       { \pagestyle_headleft:n  {#1} },
    headcenter      .code:n =       { \pagestyle_headcenter:n  {#1} },
    headright       .code:n =       { \pagestyle_headright:n  {#1} },
    headinner       .code:n =       { \pagestyle_headinner:n {#1} },
    headouter       .code:n =       { \pagestyle_headouter:n {#1} },    
    footleft        .code:n =       { \pagestyle_footleft:n  {#1} },
    footcenter      .code:n =       { \pagestyle_footcenter:n  {#1} },
    footright       .code:n =       { \pagestyle_footright:n  {#1} },
    footinner       .code:n =       { \pagestyle_footinner:n {#1} },
    footouter       .code:n =       { \pagestyle_footouter:n {#1} },
    evenheadleft    .tl_gset:N =     \g_ps_evenheadleft_tl,
    evenheadcenter  .tl_gset:N =     \g_ps_evenheadcenter_tl,
    evenheadright   .tl_gset:N =     \g_ps_evenheadright_tl,
    oddheadleft     .tl_gset:N =     \g_ps_oddheadleft_tl,
    oddheadcenter   .tl_gset:N =     \g_ps_oddheadcenter_tl,
    oddheadright    .tl_gset:N =     \g_ps_oddheadright_tl,
    evenfootleft    .tl_gset:N =     \g_ps_evenfootleft_tl,
    evenfootcenter  .tl_gset:N =     \g_ps_evenfootcenter_tl,
    evenfootright   .tl_gset:N =     \g_ps_evenfootright_tl,
    oddfootleft     .tl_gset:N =     \g_ps_oddfootleft_tl,
    oddfootcenter   .tl_gset:N =     \g_ps_oddfootcenter_tl,
    oddfootright    .tl_gset:N =     \g_ps_oddfootright_tl,
    headrule        .bool_gset:N =   \g_ps_headrule_bool,
    footrule        .bool_gset:N =   \g_ps_footrule_bool,    
    chaptermark     .bool_gset:N =   \g_ps_chaptermark_bool,
    sectionmark     .bool_gset:N =   \g_ps_sectionmark_bool,
    chapterpage     .bool_gset:N =   \g_ps_chapterpage_bool
}

\cs_new:Npn \pagestyle_headleft:n #1
{
    \tl_gset:Nn \g_ps_evenheadleft_tl {#1}
    \tl_gset:Nn \g_ps_oddheadleft_tl {#1}
}
\cs_new:Npn \pagestyle_headcenter:n #1
{
    \tl_gset:Nn \g_ps_evenheadcenter_tl {#1}
    \tl_gset:Nn \g_ps_oddheadcenter_tl {#1}
}
\cs_new:Npn \pagestyle_headright:n #1
{
    \tl_gset:Nn \g_ps_evenheadright_tl {#1}
    \tl_gset:Nn \g_ps_oddheadright_tl {#1}
}
\cs_new:Npn \pagestyle_headinner:n #1
{
    \tl_gset:Nn \g_ps_evenheadright_tl {#1}
    \tl_gset:Nn \g_ps_oddheadleft_tl {#1}
}
\cs_new:Npn \pagestyle_headouter:n #1
{
    \tl_gset:Nn \g_ps_evenheadleft_tl {#1}
    \tl_gset:Nn \g_ps_oddheadright_tl {#1}
}
\cs_new:Npn \pagestyle_footleft:n #1
{
    \tl_gset:Nn \g_ps_evenfootleft_tl {#1}
    \tl_gset:Nn \g_ps_oddfootleft_tl {#1}
}
\cs_new:Npn \pagestyle_footcenter:n #1
{
    \tl_gset:Nn \g_ps_evenfootcenter_tl {#1}
    \tl_gset:Nn \g_ps_oddfootcenter_tl {#1}
}
\cs_new:Npn \pagestyle_footright:n #1
{
    \tl_gset:Nn \g_ps_evenfootright_tl {#1}
    \tl_gset:Nn \g_ps_oddfootright_tl {#1}
}
\cs_new:Npn \pagestyle_footinner:n #1
{
    \tl_gset:Nn \g_ps_evenfootright_tl {#1}
    \tl_gset:Nn \g_ps_oddfootleft_tl {#1}
}
\cs_new:Npn \pagestyle_footouter:n #1
{
    \tl_gset:Nn \g_ps_evenfootleft_tl {#1}
    \tl_gset:Nn \g_ps_oddfootright_tl {#1}
}

\NewDocumentCommand \PageStyleSetup { m }
{
  	\keys_set:nn { pagestyle } { #1 } 
  	\PageStyleSettle{ \g_layout_type }	
}

\NewDocumentCommand \PageStyleSettle { m }
{
    % \makerunningwidth{#1}{\headwidth}    
    \bool_if:NTF \g_ps_headrule_bool
    {
        \makeheadrule{#1}{\headwidth}{\normalrulethickness}   
    }{
        \makeheadrule{#1}{0pt}{0pt}
    }
    \bool_if:NTF \g_ps_footrule_bool
    {
        \makefootrule{#1}{\headwidth}{\normalrulethickness}{1ex}
    }{
        \makefootrule{#1}{0pt}{0pt}{0pt}
    }
    \makeevenhead{#1}{\hffont\g_ps_evenheadleft_tl}{\hffont\g_ps_evenheadcenter_tl}{\hffont\g_ps_evenheadright_tl}
    \makeoddhead{#1}{\hffont\g_ps_oddheadleft_tl}{\hffont\g_ps_oddheadcenter_tl}{\hffont\g_ps_oddheadright_tl}
    \makeevenfoot{#1}{\hffont\g_ps_evenfootleft_tl}{\hffont\g_ps_evenfootcenter_tl}{\hffont\g_ps_evenfootright_tl}
    \makeoddfoot{#1}{\hffont\g_ps_oddfootleft_tl}{\hffont\g_ps_oddfootcenter_tl}{\hffont\g_ps_oddfootright_tl}
    \pagestyle{#1}
    \copypagestyle{chapter}{#1}
    \copypagestyle{normal}{#1} % for Sphinx
    \bool_if:NF \g_ps_chapterpage_bool
    {
        \makeheadrule{chapter}{0pt}{0pt}
        \makeevenhead{chapter}{}{}{}
        \makeoddhead{chapter}{}{}{}
        \copypagestyle{noheader}{chapter}
    }
    \bool_if:NTF \g_ps_chaptermark_bool
    {
        \renewcommand\chaptermark[1]{\markboth{##1}{##1}}
    }{
        \renewcommand\chaptermark[1]{}
    }
    \bool_if:NTF \g_ps_sectionmark_bool
    {
        \renewcommand\sectionmark[1]{\markright{##1}}
    }{
        \renewcommand\sectionmark[1]{}
    }
}

% one column
\cs_new:Nn \folio_common:
{
    \copypagestyle{common}{ruled}
    \setlength{\headwidth}{\textwidth}
    \PageStyleSetup{
        headrule=true,
        evenheadleft=\leftmark,
        oddheadright=\rightmark,
        evenfootleft=\thepage,
        oddfootright=\thepage,
        chaptermark=true,
        sectionmark=false,
    }
}

% vartwo column
\cs_new:Nn \folio_vartwo:
{
    \copypagestyle{vartwo}{companion}        
    \setlength\vartwosecindent{\marginparwidth}
    \addtolength\vartwosecindent{\marginparsep}
    \if@twocolumn
        \setlength{\headwidth}{\columnwidth}
    \else
        \setlength{\headwidth}{\textwidth}
    \fi
    \addtolength{\headwidth}{\vartwosecindent}    
    \makeheadposition{vartwo}{flushright}{flushright}{flushright}{flushright}
    \PageStyleSetup{
        headrule=true,
        evenheadleft=\leftmark,
        oddheadright=\rightmark,
        evenfootleft=\thepage,
        oddfootright=\thepage,
        chaptermark=true,
        sectionmark=false,
    }
}

% setup -----------------------------------------------------------------------

\keys_define:nn { HzLayout }
{
    paper           .code:n = { \layout_paper_configure:n {#1} },
    stockwidth      .dim_gset:N = \stockwidth,
    stockheight     .dim_gset:N = \stockheight,
    paperwidth      .dim_gset:N = \paperwidth,
    paperheight     .dim_gset:N = \paperheight,
    landscape       .bool_gset:N = \g_layout_landscape_bool,
    column          .code:n = { \layout_column_configure:n {#1} },
    ulmargin        .dim_gset:N = \ulmargin,
    ulratio         .tl_gset:N = \ulratio, % specify after column
    lrmargin        .dim_gset:N = \lrmargin,
    vartwomargin    .dim_gset:N = \vartwomargin,
    showtrims       .bool_gset:N = \g_layout_showtrims_bool,
    showlayout      .bool_gset:N = \g_layout_showlayout_bool,
    hook            .tl_gset:N = \g_layout_hook
}

\bool_set_false:N \g_layout_showtrims_bool

\NewDocumentCommand \LayoutSetup { s m }
{
    \keys_set:nn { HzLayout } { #2 }
    \IfBooleanF{#1}{
        \layout_settle:
    }
    \bool_if:NT \g_layout_showlayout_bool
    {
        \AtBeginDocument{ \ShowPageLayout }
    }
}
\LayoutSetup*{paper=A4, column=one}

\cs_new:Nn \layout_settle:
{
    \bool_if:NT \g_layout_landscape_bool
    { 
        \layout_turn_tolandscape: 
    }
    \bool_if:NTF \g_layout_showtrims_bool
    {
        \showtrimson
        \setstocksize{\stockheight}{\stockwidth}
        \settrimmedsize{\paperheight}{\paperwidth}{*}
        \dim_set:Nn \trimtop {\stockheight-\paperheight}
        \dim_set:Nn \trimedge {\stockwidth-\paperwidth}
        \settrims{.5\trimtop}{.5\trimedge}
        \renewcommand*{\shipout}{\afterassignment\mem@shipi\setbox\@cclv=}
		\quarkmarks %\trimLmarks
    }{
        \showtrimsoff
        \setstocksize{\paperheight}{\paperwidth}
        \settrimmedsize{\paperheight}{\paperwidth}{*}
    }
    \str_case:VnF \g_layout_type
    {
        { common }    { \layout_settle_common: }
        { vartwo }    { \layout_settle_vartwo: }
        { slide }    { \layout_settle_slide: }
        { arbitrary }  { \layout_settle_arbitrary: }
    }{ 
        \layout_settle_common: 
    }
}

\cs_new:Nn \layout_turn_tolandscape:
{
    \setlength\@tempdima  {\stockheight}
    \setlength\stockheight{\stockwidth}
    \setlength\stockwidth {\@tempdima}
    \setlength\@tempdima  {\paperheight}
    \setlength\paperheight{\paperwidth}
    \setlength\paperwidth {\@tempdima}
}

\cs_new:Nn \layout_settle_common:
{
    \layout_column_one:
    \folio_common:
    \SetObjectAlign{\raggedright}
}

\cs_new:Nn \layout_settle_vartwo:
{
    \layout_column_vartwo:
    \folio_vartwo:
    \tl_set:Nn \chapteralign {\raggedleft}
    \SetObjectAlign{\raggedright}
}

\cs_new:Nn \layout_settle_slide:
{
    \layout_slide:
    \pagestyle{empty}
    \copypagestyle{chapter}{plain}
    \SetObjectAlign{\centering}
}

\cs_new:Nn \layout_settle_arbitrary:
{
    \layout_arbitrary:
    \tl_set:Nn \hffont {\footnotesize}
    \makeevenfoot{plain}{}{\hffont\thepage}{}
    \makeoddfoot{plain}{}{\hffont\thepage}{}
    \pagestyle{plain}
    \copypagestyle{chapter}{plain}
    \SetObjectAlign{\centering}
}

% headings * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% style components for chapter and section ------------------------------------

\NewDocumentCommand \Chapter { m } % phantom chapter
{
    \chapter*{#1}
    \phantomsection
    \addcontentsline{toc}{chapter}{#1}
}

\NewDocumentCommand \chapterline {}
{
    \chapteralign
    \chapterfont
    \color{\chaptercolor}
}

\NewDocumentCommand \SectionRule { m }
{
    \secstyle #1
    \nopagebreak\vskip-\onelineskip
    \hspace*{-\vartwosecindent}
    \IfVartwo
    {
        \rule{\headwidth}{0.75pt}
    }[
        \if@twocolumn
            \rule{\columnwidth}{0.75pt}
        \else
            \rule{\textwidth}{0.75pt}
        \fi
    ]
}

\NewDocumentCommand \SectionMultilineRule { m }
{
    \SectionMultiline 
    { 
        #1
        \nopagebreak\vskip-1\onelineskip
        \IfVartwo        {
            
            \rule{\headwidth}{0.75pt}
        }[
            \if@twocolumn
                \rule{\columnwidth}{0.75pt}
            \else
                \rule{\textwidth}{0.75pt}
            \fi
        ]
    }
}

\NewDocumentCommand \SectionMultiline { m }
{    
    \hspace*{-\vartwosecindent}
    \makebox[0pt][l]{
        \parbox[t]{\textwidth+\vartwosecindent}{\secstyle #1}
    }
}

\NewDocumentCommand \SubsectionMultiline { m }
{    
    \hspace*{-\vartwosecindent}
    \makebox[0pt][l]{
            \parbox[t]{\textwidth+\vartwosecindent}{\subsecstyle #1}
    }
}

\NewDocumentCommand \sectionline {}
{
    \sectionalign 
    \sectionfont 
    \color{\sectioncolor}
}

\newcommand\secstyle{ \sectionline\secfontsize }
\newcommand\subsecstyle{ \sectionline\subsecfontsize }
\newcommand\subsubsecstyle{ \sectionline\subsubsecfontsize }
\setsecheadstyle{ \secstyle }
\setsubsecheadstyle{ \subsecstyle }
\setsubsubsecheadstyle{ \subsubsecstyle }

% style configuration --------------------------------------------------------

\cs_new:Npn \style_type_configure:n #1
{
    \str_case:nn {#1}
    {
        { article }     { \style_type_article: }
    }
}

\cs_new:Nn \style_type_article:
{
    \IfVartwo
    { 
        \copypagestyle{article}{vartwo} 
    }[ 
        \copypagestyle{article}{plain} 
    ]
    \makeheadrule{article}{0pt}{0pt}
    \makeoddhead{article}{}{}{}
    \makeoddfoot{article}{}{\hffont\thepage}{}
    \makeevenhead{article}{}{}{}
    \makeevenfoot{article}{}{\hffont\thepage}{}
    \pagestyle{article}
    \aliaspagestyle{chapter}{article}
    \counterwithout{section}{chapter}
    \counterwithout{figure}{chapter}
    \counterwithout{table}{chapter}
    % \setsecnumdepth{section}
    \style_cft_configure:n {section}
}

\cs_new:Npn \style_cft_configure:n #1
{
    \str_case:nn {#1}
    {
        {section}  { \style_cft_section: }
        {none}     { \addtodef{ \tableofcontents }{ \markboth{}{} }{} }
    }
}

\cs_new:Nn \style_cft_section:
{
    \renewcommand\@tocmaketitle{
        \section*{\contentsname}
        \markboth{\contentsname}{\contentsname}
    }
    \renewcommand\@lofmaketitle{
        \section*{\listfigurename}
        \markboth{\listfigurename}{\listfigurename}
    }
    \renewcommand\@lotmaketitle{
        \section*{\listtablename}
        \markboth{\listtablename}{\listtablename}
    }
}

\cs_new:Npn \style_chapter_configure:n #1
{
    \chapterstyle{#1}
}

% multiline: 
\cs_new:Npn \style_section_configure:n #1
{
    \clist_map_variable:nNn {#1} \l_tmpa_tl
    {
        \str_case:Vn \l_tmpa_tl
        {
            { firm }      { \style_section_firm: }
            { sparse }    { \style_section_sparse: }
            { tight }     { \style_section_tight: }
            { multiline } { \style_section_multiline: }
            { rule }      { \style_section_rule: }
        }
    }
}

%\setbeforesecskip{-3.5ex \@plus -1ex \@minus -.2ex}
%\setbeforesubsecskip{-3.25ex \@plus -1ex \@minus -.2ex}
%\setbeforesubsubsecskip{-3.25ex \@plus -1ex \@minus -.2ex}
%\setaftersecskip{2.3ex \@plus .2ex}
%\setaftersubsecskip{1.5ex \@plus .2ex}
%\setaftersubsubsecskip{1.5ex \@plus .2ex}
%\setbeforeparaskip{3.25ex \@plus 1ex \@minus .2ex}
%\setafterparaskip{-1em}

\cs_new:Nn \style_section_firm:
{
    \setbeforesecskip{-3.25ex \@plus -.5ex \@minus -.1ex}
    \setbeforesubsecskip{-3ex \@plus -.5ex \@minus -.1ex}
    \setbeforesubsubsecskip{-2.75ex \@plus -.5ex \@minus -.1ex}
    \setaftersecskip{2ex \@plus .1ex}
    \setaftersubsecskip{1.5ex \@plus .1ex}
    \setaftersubsubsecskip{1.25ex \@plus .1ex}
}

\cs_new:Nn \style_section_sparse:
{
    \setbeforesecskip{-4ex \@plus -.5ex \@minus -.1ex}
    \setbeforesubsecskip{-3.5ex \@plus -.5ex \@minus -.1ex}
    \setbeforesubsubsecskip{-3.25ex \@plus -.5ex \@minus -.1ex}
    \setaftersecskip{2.75ex \@plus .1ex}
    \setaftersubsecskip{2.25ex \@plus .1ex}
    \setaftersubsubsecskip{1.75ex \@plus .1ex}
}

\cs_new:Nn \style_section_tight:
{
    \setbeforesecskip{-2.25ex \@plus -.25ex \@minus -.1ex}
    \setbeforesubsecskip{-2ex \@plus -.25ex \@minus -.1ex}
    \setbeforesubsubsecskip{-1.75ex \@plus -.25ex \@minus -.1ex}
    \setaftersecskip{1.5ex \@plus .1ex}
    \setaftersubsecskip{1.25ex \@plus .1ex}
    \setaftersubsubsecskip{1ex \@plus .1ex}
}

\cs_new:Nn \style_section_multiline:
{
    \bool_if:NT \g_column_vartwo_bool
    {
        \bool_gset_true:N \g_section_multiline_bool    
        \setsecheadstyle{ \SectionMultiline }
        \setsubsecheadstyle{ \SubsectionMultiline }
    }
}

\cs_new:Nn \style_section_rule:
{
    \bool_if:NTF \g_section_multiline_bool
    {
        \setsecheadstyle{ \SectionMultilineRule }    
    }{
        \setsecheadstyle{ \SectionRule }
    }
}

\cs_new:Npn \style_paragraph_configure:n #1
{
    \str_case:nn {#1}
    {
        { indent }   { \style_paragraph_indent: }
        { interval }   { \style_paragraph_interval: }
    }
}

\cs_new:Nn \style_paragraph_indent:
{
    \abnormalparskip{0pt}
    \setlength{\parindent}{\hzparindent}
    \SetTextStyle{\noindent\setlength\parindent{\hzparindent}}
    \setlist{partopsep=0pt, topsep=.25\baselineskip, itemsep=.25ex}
    \setlist[itemize]{labelindent=.5em,labelwidth=1em,labelsep=.5em}
    \setlist[enumerate]{labelindent=.5em,labelwidth=1.25em,labelsep=.5em}
    \TermsInitialize{top-sep=0.5\baselineskip,item-sep=.5ex}
}

\cs_new:Nn \style_paragraph_interval:
{
    \abnormalparskip{\hzparskip}
    \setlength{\parindent}{0em}    
    \setlist{partopsep=0pt, topsep=.5ex, itemsep=0pt}
    \setlist[itemize]{labelindent=0em,labelwidth=1em,labelsep=.5em}
    \setlist[enumerate]{labelindent=0em,labelwidth=1.25em,labelsep=.5em}
    \TermsInitialize{top-sep=0.5ex,item-sep=.25ex}
}

\bool_new:N \g_section_multiline_bool
\keys_define:nn { HzHeading }
{
    linespacing           .code:n = { \setSpacing {#1} },
    type                  .code:n = { \style_type_configure:n {#1} },
    cftstyle              .code:n = { \style_cft_configure:n {#1} },
    chapterwider          .bool_set:N = \g_style_chapterwider_bool,
    chapteralign          .tl_set:N = \chapteralign,
    chapterfont           .tl_set:N = \chapterfont,
    chaptercolor          .tl_set:N = \chaptercolor,
    chapternamesize       .tl_set:N = \chapternamesize,
    chapternumbersize     .tl_set:N = \chapternumbersize,
    chaptertitlesize      .tl_set:N = \chaptertitlesize,
    chapterstyle          .code:n = { \style_chapter_configure:n {#1} },
    nochaptername         .bool_set:N = \g_style_nochaptername_bool,
    chaptercontents       .bool_set:N = \g_chapter_contents_bool,
    sectionalign          .tl_set:N = \sectionalign,
    sectionfont           .tl_set:N = \sectionfont,
    sectioncolor          .tl_set:N = \sectioncolor,
    sectionstyle          .code:n = { \style_section_configure:n {#1} },
    sectionsize           .tl_set:N = \secfontsize,
    subsectionsize        .tl_set:N = \subsecfontsize,
    subsubsectionsize     .tl_set:N = \subsubsecfontsize,
    paragraphstyle        .code:n = { \style_paragraph_configure:n {#1} },
    parskip               .skip_set:N = \hzparskip,
    parindent             .skip_set:N = \hzparindent
}

\NewDocumentCommand \HeadingSetup { m }
{
    \keys_set:nn { HzHeading } {#1}
    \bool_if:NT \g_style_nochaptername_bool
    {
        \def\@chapapp{}
        \IfDefined{\prenum}{ \renewcommand\prenum{} }
    }
    \bool_if:NT \g_column_vartwo_bool
    {
        \bool_if:NT \g_style_chapterwider_bool
        {            
            \patchcommand{\@makechapterhead}{\begin{adjustwidth}{-\vartwosecindent}{0pt}}{\end{adjustwidth}}
            \patchcommand{\@makeschapterhead}{\begin{adjustwidth}{-\vartwosecindent}{0pt}}{\end{adjustwidth}}
            \patchcommand\printtoctitle{\hspace*{-\vartwosecindent}}{}
            \patchcommand\printlottitle{\hspace*{-\vartwosecindent}}{}
            \patchcommand\printloftitle{\hspace*{-\vartwosecindent}}{}
        }  
        \bool_if:NTF \g_section_multiline_bool
        {
            \setsecindent{0pt}
            \setsubsecindent{0pt}
        }{
            \setsecindent{-\vartwosecindent}
            \setsubsecindent{-\vartwosecindent}
        }
    }
    \bool_if:NT \g_chapter_contents_bool
    {
        \EnableChapterContents
    }
}

\HeadingSetup{
    linespacing=1.25,
    chapterfont=\normalfont\bfseries,
    chaptercolor=black,
    sectionalign=\raggedright, %\memRTLraggedright,
    sectionfont=\normalfont\bfseries,
    sectioncolor=black,
    sectionsize=\Large,
    subsectionsize=\large,
    subsubsectionsize=\normalsize,
    parskip=.25\baselineskip,
    parindent=1em
}

\NewDocumentCommand \TableOfContents { s o }
{
    \group_begin:
    \IfValueT { #2 }{ \setSpacing{#2} }
    \IfBooleanTF {#1} 
    { 
        \pdfbookmark[0]{\contentsname}{Contents}
        \tableofcontents*
    }{ 
        \tableofcontents 
    }
    \group_end:
}

\NewDocumentCommand \topic { s m }
{
    \IfBooleanTF {#1}
        { \subsection*{#2} }
        { \subsubsection*{#2} }
}

\NewDocumentCommand \Appendix {}
{
    \appendix
    \addtocontents{toc}{\protect\contentsline{chapter}{\appendixname}{}{}}
}

% chapter styles
% \CJKchapterstyle: chapter name
% \CJKchapterstyle*: chapter number
\NewDocumentCommand \CJKchapterstyle { s }
{
    \IfBooleanTF {#1}
    {
        \bool_if:NTF \g_CJK_bool
        {
            \ifanappendix 
				\chapnumfont\thechapter 
			\else 
				\chapnumfont\thechapter\space\chapnamefont\@chapapp 
			\fi
        }{
            \chapnumfont\thechapter
        }
    }{
        \bool_if:NTF \g_CJK_bool
        {
            \ifanappendix 
				\chapnamefont\@chapapp
			\else 
				\chapnamefont\prenum
			\fi
        }{
            \chapnamefont\@chapapp
        }
    }
}

\makechapterstyle{null}{
    \renewcommand{\chapnamefont}{\huge\chapterline\chapternamesize}
    \renewcommand{\chapnumfont}{\HUGE\chapterline\chapternumbersize}
    \renewcommand{\chaptitlefont}{\Huge\chapterline\chaptertitlesize}
}

\makechapterstyle{hzchapter}{
    \chapterstyle{null}
    \setlength{\midchapskip}{6ex}
    \renewcommand{\printchaptername}{\CJKchapterstyle}
    \renewcommand{\printchapternum}{\CJKchapterstyle*}
}

\makechapterstyle{hzchaptertight}{
    \chapterstyle{null}
    \setlength{\beforechapskip}{3\baselineskip}
    \setlength{\midchapskip}{.25\baselineskip}
    \setlength{\afterchapskip}{2\baselineskip}
    \renewcommand{\printchaptername}{\CJKchapterstyle}
    \renewcommand{\printchapternum}{\CJKchapterstyle*}
}

\makechapterstyle{hzarticle}{
    \chapterstyle{article}
    \renewcommand{\chapnamefont}{\huge\chapterline\chapternamesize}
    \renewcommand{\chapnumfont}{\HUGE\chapterline\chapternumbersize}
    \renewcommand{\chaptitlefont}{\Huge\chapterline\chaptertitlesize}	
}

% \makechapterstyle{hzarticlefirm}{
%     \chapterstyle{null}
%     \setlength{\beforechapskip}{\baselineskip}
%     \setlength{\midchapskip}{0pt}
%     \setlength{\afterchapskip}{\baselineskip}
%     \renewcommand{\chapterheadstart}{\vspace*{\beforechapskip}}
%     \renewcommand{\printchaptername}{}
%     \renewcommand{\chapternamenum}{}
%     \renewcommand{\printchapternum}{\chapnumfont\thechapter\quad}
%     \renewcommand{\afterchapternum}{}
% }

% heading utilities -----------------------------------------------

\newcounter{unsec}[chapter] % when \setsecnumdepth{chapter} is declared
\newcounter{unsubsec}[unsec]

\tl_new:N \g_common_text_style 
\NewDocumentCommand \SetTextStyle { m o } 
{
    \tl_gset:Nn \g_common_text_style {#1}
    \IfValueT { #2 }
    {
        #2
        \renewcommand{\@makefntext}[1]{\makefootmark#2 ##1}
    }
}

\AtBeginDocument{    
    \setlength{\verbatimindent}{0pt}
    \renewcommand*{\verbatimbreakchar}{}
}

\NewDocumentCommand \SectionNewpageOn { s }
{
	\IfBooleanTF { #1 }
	{
		\setsechook{\newpage}
	}{
		\int_compare:nTF { \value{secnumdepth} < 1 }
		{
			\setsechook {
				\int_compare:nT { \value{unsec} > 0 } { \newpage }
				\stepcounter{unsec}
			}
		}{
			\setsechook {
				\int_compare:nT { \value{section} > 0 } { \newpage }
			}
		}
	}
}
\NewDocumentCommand \SectionNewpageOff {}
{  
    \setsechook{} 
}

\NewDocumentCommand \SubsectionNewpageOn {}
{
    \int_compare:nTF { \value{secnumdepth} < 2 }
    {
        \setsubsechook {
            \int_compare:nT { \value{unsubsec} > 0 } { \newpage }
            \stepcounter{unsubsec}
        }
    }
    {
        \setsubsechook {
            \int_compare:nT { \value{subsection} > 0 } { \newpage }
        }
    }
}
\NewDocumentCommand \SubsectionNewpageOff {}
{
    \setsubsechook{} 
}

\NewDocumentEnvironment {SectionNewpage} {}
{ 
    \SectionNewpageOn 
}{ 
    \SectionNewPageOff
}

% objects ---------------------------------------------------------------------

\newtcbox{\objectframe}{
    colframe=\g_object_frame_color,
    colback=white,
    boxrule=0.5pt,
    arc=0pt,
    boxsep=3pt,
    top=0pt, bottom=0pt, left=0pt, right=0pt
}

\keys_define:nn { HzObject }
{
    beforeskip  .skip_gset:N = \g_object_before_skip,
    afterskip  .skip_gset:N = \g_object_after_skip,
    framecolor  .tl_set:N = \g_object_frame_color
}

\NewDocumentCommand \ObjectSetup { m }
{
    \keys_set:nn { HzObject } { #1 }
}

\cs_new:Npn \object_skip_before:n #1
{
    \dim_compare:nTF { #1 != 0pt }
    { 
        \skip_set:Nn \l_tmpa_skip {#1} 
    }{ 
        \skip_set:Nn \l_tmpa_skip {\g_object_before_skip} 
    }
    \vspace{\l_tmpa_skip}\noindent
}

\cs_new:Npn \object_skip_after:n #1
{
    \dim_compare:nTF { #1 != 0pt }
    { 
        \skip_set:Nn \l_tmpa_skip {#1} 
    }{ 
        \skip_set:Nn \l_tmpa_skip {\g_object_after_skip} 
    }
    \vspace{\l_tmpa_skip}
}

\cs_new:Npn \object_locate:N #1
{
    \group_begin:
    \dim_set_eq:NN \l_tmpb_dim #1
    \dim_compare:nT { \l_tmpb_dim > \linewidth }
    {
        \dim_sub:Nn \l_tmpb_dim { \linewidth }
        \IfVartwo{ \hspace*{-\l_tmpb_dim} }[ \hspace*{-.5\l_tmpb_dim} ]
    }
    \group_end:
	\dim_compare:nT { #1 < \linewidth }
	{
		\dim_set_eq:NN #1 \linewidth
	}
}

\ObjectSetup{
    beforeskip=.4\baselineskip,
    afterskip=.6\baselineskip,
    framecolor=gray
}

% actions

\keys_define:nn { action }
{
    beforeskip  .skip_set:N = \l_action_before_skip,
    afterskip   .skip_set:N = \l_action_after_skip,
    font        .tl_set:N = \l_action_font,
    delimiter   .tl_set:N = \l_action_delimiter,
    inline      .bool_set:N = \l_action_inline_bool  
}

\NewDocumentCommand \ActionSetup { m }
{
    \keys_set:nn {action} {#1}
}

\ActionSetup {
    beforeskip = 0.5\hzparskip,
    afterskip = -\hzparskip,
    font = \bfseries,
	delimiter = :,
    inline = true,
}

\NewDocumentCommand \action { m }
{
    \object_skip_before:n {\l_action_before_skip}
    \group_begin:        
        \l_action_font #1
    \group_end:
    \bool_if:NTF \l_action_inline_bool
    { 
        \l_action_delimiter \space 
    }{ 
        \nopagebreak\par\object_skip_after:n {\l_action_after_skip} 
    }
}

% hyperlinks

\NewDocumentCommand \DecolorHyperlinks { s O {darkgray} O {\bfseries} }
{
	\hypersetup{
		pdfborder={0 0 0}, 
		plainpages=false,
	}
	\IfBooleanTF {#1}
	{		
		\hypersetup{allcolors=#2} % colorlinks=true
	}{
		\hypersetup{colorlinks=false}
    	\renewcommand{\theTitleReference}[2]{\textcolor{#2}{#3 ##2}}
	}
}

% graphics * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

\NewDocumentCommand \includegraphicsvoid {}
{
    \cs_set_eq:NN \orgincludegraphics \includegraphics
    \renewcommand\includegraphics[2][]{\orgincludegraphics{uncertain}}
}

\graphicspath{ {images/}{../images/}{../../images/} }

\NewDocumentCommand \ShowGraphicspath {}
{
    \group_begin:
        \tiny
        \Ginput@path
    \group_end:
}

% captions --------------------------------------------------------------------

\newfixedcaption{\imgcaption}{figure}
\newfixedcaption{\tabcaption}{table}

\keys_define:nn  { HzCaption }{

    beforeskip  .skip_gset:N = \g_caption_before_skip,
    afterskip   .skip_gset:N = \g_caption_after_skip,
    align       .tl_gset:N = \g_caption_align_tl,
	align-short .tl_gset:N = \g_caption_align_short_tl,
    font        .tl_gset:N = \g_caption_font_tl,
    delimiter   .tl_gset:N = \g_caption_delimiter_tl
}

\NewDocumentCommand \CaptionSetup { m }
{
    \keys_set:nn { HzCaption } { #1 }
    \dim_set_eq:NN \abovecaptionskip \g_caption_before_skip
    \dim_set_eq:NN \belowcaptionskip \g_caption_after_skip
    \captionnamefont{ \g_caption_font_tl }
    \captiontitlefont{ \g_caption_font_tl }
    \captiondelim{ \g_caption_delimiter_tl }
    \captionstyle[\g_caption_align_short_tl]{ \g_caption_align_tl }
    %\captionstyle{ \g_caption_align_tl }
}

\CaptionSetup{
    beforeskip = 1ex,
    align = \raggedright,
	align-short = \raggedright,
    font = \rmfamily\bfseries\small,
    delimiter=:\space,
    afterskip = 1ex
}

% common variables ------------------------------------------------------------

\dim_zero_new:N \g_protrude_dim
\box_new:N \l_image_box
\box_new:N \l_text_box

% \image*|[options]{image}[extra image](caption)<short caption> -------------------------------------

\keys_define:nn { image }
{
    beforeskip    	.skip_set:N = \l_image_before_skip,
    afterskip     	.skip_set:N = \l_image_after_skip,
    extraskip     	.skip_set:N = \l_image_extra_skip,
    float         	.bool_set:N = \l_image_float_bool,
	float-placement	.tl_set:N	= \l_image_float_placement_tl,
    frame         	.bool_set:N = \l_image_frame_bool,
    fitline       	.bool_set:N = \l_image_fitline_bool, % fit images to the specified width; not valid when an extra image is given.
    fitwidth      	.tl_set:N 	= \l_image_fitwidth_tl,
    scale         	.tl_set:N 	= \l_image_scale_tl,
    flush         	.bool_set:N = \l_image_flush_bool, % flush images into the left margin
    landscape     	.bool_set:N = \l_image_landscape_bool,
    align         	.tl_set:N 	= \l_image_align,
	middle			.bool_set:N = \l_image_vertical_middle_bool,
    caption       	.tl_set:N 	= \l_image_caption_tl,
	caption-short  	.tl_set:N 	= \l_image_caption_short_tl,
	caption-ignore	.bool_set:N = \l_image_caption_ignore_bool,
	caption-fit		.bool_set:N = \l_image_caption_fit_bool, % fit the caption to the image width
    label         	.tl_set:N 	= \l_image_label_tl,
    legend        	.bool_set:N = \l_image_legend_bool,
    showfilename  	.bool_set:N = \l_image_showfilename_bool,
    star          	.tl_set:N 	= \l_image_star_tl,
    vbar          	.tl_set:N 	= \l_image_vbar_tl
}
\bool_new:N \l_image_extra_bool

\NewDocumentCommand \ImageSetup { m }
{
    \keys_set:nn { image } {#1}
	\exp_args:NNx \def\fps@figure { \l_image_float_placement_tl }
}

\ImageSetup{
    beforeskip=0pt,
    afterskip=0pt,
    extraskip=1em,
    float=false,
	float-placement=tbh,
    frame=false,
    fitline=false,
    fitwidth=\linewidth,
    scale=1,
    landscape=false,
    legend=false,
    showfilename=false,
    star=frame,
    vbar=landscape
}

\NewDocumentCommand \image { s t| O{} m o d() d<> }
{
    \group_begin:
    \IfValueTF{ #5 } 
    {
        \bool_set_true:N \l_image_extra_bool
    }{
        \bool_set_false:N \l_image_extra_bool
    }
    \IfBooleanT{ #1 }
    { 
        \exp_args:No \ImageSetup{\l_image_star_tl} 
    }
    \IfBooleanT{ #2 }
    { 
        \exp_args:No \ImageSetup{\l_image_vbar_tl} 
    }
    \ImageSetup{#3}
    \IfValueT{ #6 }
    { 
        \tl_set:Nn \l_image_caption_tl { #6 } 
    }
	\IfValueT{ #7 }
    { 
        \tl_set:Nn \l_image_caption_short_tl { #7 } 
    }
    \tl_if_empty:NT \l_image_label_tl
    {
        \IfValueTF{#5} 
		{
            \tl_set:No \l_image_label_tl { #4-#5 }
        }{
            \tl_set:No \l_image_label_tl { #4 }
        }
    }
    \exp_args:Nxx \image_save:nn { #4 } { #5 }
    \bool_if:NTF \l_image_float_bool {
        \begin{figure}
        \image_put:
        \end{figure}
    }{
		\bool_if:NTF \l_image_vertical_middle_bool
		{
			\begin{vplace} % vertically centering
		}{
        	\object_skip_before:n {\l_image_before_skip}
		}
        \image_put:
		\bool_if:NTF \l_image_vertical_middle_bool
		{
			\end{vplace}
		}{
        	\object_skip_after:n {\l_image_after_skip}
		}
    }
    \group_end:
}

\cs_new:Npn \image_save:nn #1 #2
{
    \bool_if:NTF \l_image_frame_bool
    {
        \bool_if:NTF \l_image_extra_bool {
            \hbox_set:Nn \l_image_box{
                \objectframe{
                    \includegraphics[scale=\l_image_scale_tl]{#1}
                    \hspace{\l_image_extra_skip}
                    \includegraphics[scale=\l_image_scale_tl]{#2}
                }
            }
        }{
            \hbox_set:Nn \l_image_box{
                \objectframe{
                    \includegraphics[scale=\l_image_scale_tl]{#1}
                }
            }
            \bool_if:NT \l_image_fitline_bool
            {
                \dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_image_box }                
                \dim_compare:nT { \l_tmpa_dim > \l_image_fitwidth_tl }
                {
                    \hbox_set:Nn \l_image_box{
                        \objectframe{
                            \includegraphics[width=\l_image_fitwidth_tl]{#1}
                        }
                    }
                }
            }
        }
     }{
         \bool_if:NTF \l_image_extra_bool {
            \hbox_set:Nn \l_image_box{
                    \includegraphics[scale=\l_image_scale_tl]{#1}
                    \hspace{\l_image_extra_skip}
                    \includegraphics[scale=\l_image_scale_tl]{#2}
            }
        }{
            \hbox_set:Nn \l_image_box{
                    \includegraphics[scale=\l_image_scale_tl]{#1}
            }
            \bool_if:NT \l_image_fitline_bool
            {
                \dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_image_box }
                \dim_compare:nT { \l_tmpa_dim > \l_image_fitwidth_tl }
                {
                    \hbox_set:Nn \l_image_box{
                        \includegraphics[width=\l_image_fitwidth_tl]{#1}
                    }
                }
            }
        }
     }
}

\cs_new:Nn \image_put:
{
    \bool_if:NTF \l_image_landscape_bool
    {
		\image_put_landscape: 
	}{ 
		\image_put_portrait: 
	}
}

\cs_new:Nn \image_put_portrait:
{
    \bool_if:NTF \l_image_flush_bool
    {
        \hspace*{-\vartwosecindent}
    }{		
        \dim_compare:nTF { \g_protrude_dim > 0pt }
        {
            \dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_image_box }
            \object_locate:N \l_tmpa_dim			
        }{
			\dim_set_eq:NN \l_tmpa_dim \linewidth
		}
    }
    \begin{minipage}{\l_tmpa_dim}
        \l_image_align\mbox{}
        \box_use:N \l_image_box
        \image_caption:
    \end{minipage}
}

\cs_new:Nn \image_put_landscape:
{
    \dim_compare:nTF { \g_protrude_dim > 0pt }
    {
        \dim_set_towidth:Nn \l_tmpb_dim { \box_use:N \l_image_box }
        \dim_set_toheight:Nn \l_tmpa_dim { \box_use:N \l_image_box }
        \object_locate:N \l_tmpa_dim
    }{
            \dim_set:Nn \l_tmpb_dim { \linewidth }
    }
    \rotatebox{-90}{
        \begin{minipage}{\l_tmpb_dim}
            \l_image_align\mbox{}
            \box_use:N \l_image_box
            \image_caption:
        \end{minipage}
    }
}

\cs_new:Nn \image_caption:
{
    \bool_if:NT \l_image_showfilename_bool
    {
        \tl_set:Nx \l_tmpa_tl { \l_image_label_tl }
        \legend{\tl_to_str:N \l_tmpa_tl}
    }	
	\bool_if:NT \l_image_caption_fit_bool
	{
		\dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_image_box }
		\captionwidth{\l_tmpa_dim}
		\changecaptionwidth
	}
    \tl_if_empty:NF \l_image_caption_tl
	{
		\bool_if:NF \l_image_caption_ignore_bool
		{
			\bool_if:NTF \l_image_legend_bool
			{
				\legend{\l_image_caption_tl}
			}{
				\tl_if_empty:NTF \l_image_caption_short_tl
				{
					\imgcaption{\l_image_caption_tl}
					
				}{
					\imgcaption[\l_image_caption_short_tl]{\l_image_caption_tl}				
				}
				\label{\l_image_label_tl}
			}
		}
	}
}

%\illustimage*^[ options ]{ image filename }( caption ){ description } -------------------------------
%\illustimage*: user-specified action
%\illustimage^: another user-specified action

\dim_new:N \l_illustimage_image_width_dim
\dim_new:N \l_illustimage_text_width_dim

\bool_new:N \in_illustimage_bool
\keys_define:nn { illustimage }
{
    first           .bool_set:N = \l_illustimage_first_bool,
    firstskip       .skip_set:N = \l_illustimage_first_skip,
    beforeskip      .skip_set:N = \l_illustimage_before_skip,
    afterskip       .skip_set:N = \l_illustimage_after_skip,
    frame           .bool_set:N = \l_illustimage_frame_bool,
    gap             .dim_set:N = \l_illustimage_gap_dim,
    scale           .tl_set:N = \l_illustimage_scale_tl,
    position        .tl_set:N = \l_illustimage_position_tl,
    voffset         .skip_set:N = \l_illustimage_voffset_skip,
    valign          .tl_set:N = \l_illustimage_valign_tl,
    caption         .tl_set:N = \l_illustimage_caption,
	caption-ignore	.bool_set:N = \l_illustimage_caption_ignore_bool,
	caption-align	.tl_set:N = \l_illustimage_caption_align_tl,
    label           .tl_set:N = \l_illustimage_label,
    legend          .bool_set:N = \l_illustimage_legend_bool,
    min-width       .dim_set:N = \l_illustimage_minimum_width_dim, 
	image-align		.tl_set:N = \l_illustimage_image_align_tl, % this is effective when min-width is specified
    broad           .bool_set:N = \l_illustimage_broad_bool, % take the full width in case of vartwo
    flush           .bool_set:N = \l_illustimage_flush_bool,
    showfilename    .bool_set:N = \l_illustimage_showfilename_bool,
    textstyle       .tl_set:N = \l_illustimage_textstyle_tl,
    star            .tl_set:N = \l_illustimage_star_tl,
    enum            .tl_set:N = \l_illustimage_enum_tl,
    hook            .tl_set:N = \l_illustimage_hook_tl
}

\NewDocumentCommand \IllustImageSetup { m }
{
    \keys_set:nn { illustimage } { #1 }
	\tl_if_empty:NT \l_illustimage_caption_align_tl
	{
		\tl_set:NV \l_illustimage_caption_align_tl \g_caption_align_tl
	}
}

\IllustImageSetup{
    first=false,  
    beforeskip=.15\baselineskip,
    afterskip=.15\baselineskip,
    firstskip=.5\baselineskip,
    frame=false,
    min-width=0pt,
    position=left,
    voffset=0pt,
    valign=t,
    scale=1,
    legend=false,
    showfilename=false,
    gap=1em,
    textstyle=\sloppy,
    broad=false
}

\NewDocumentCommand \illustimage { s t^ O{} m d() +m }
{
    \group_begin:
	\dim_zero:N \l_illustimage_image_width_dim
	\dim_zero:N \l_illustimage_text_width_dim
    \bool_set_true:N \in_illustimage_bool
    \IfBooleanT {#1}
    { 
		\exp_args:No \IllustImageSetup{\l_illustimage_star_tl} 
	}
    \IfBooleanT {#2}
    { 
		\IllustImageSetup{first=true} 
	}
    \IllustImageSetup{#3}
    \bool_if:NT \l_illustimage_broad_bool
    {
        \bool_if:NT \g_column_vartwo_bool
        {
			\begin{adjustwidth}{-\vartwosecindent}{0pt} 
		}
    }
	\tl_use:N \l_illustimage_hook_tl
    \IfValueT{#5} { \tl_set:Nn \l_illustimage_caption {#5} }
    % save image & text
    \tl_if_empty:NT \l_illustimage_label
    {
        \tl_set:Nn \l_illustimage_label {#4}
    }
    \bool_if:NTF \l_illustimage_frame_bool
    {
        \hbox_set:Nn \l_image_box
            { \objectframe{\includegraphics[scale=\l_illustimage_scale_tl]{#4}} }
     }{
         \hbox_set:Nn \l_image_box
             { \includegraphics[scale=\l_illustimage_scale_tl]{#4} }
     }
	\dim_set_towidth:Nn \l_illustimage_image_width_dim { \box_use:N \l_image_box }
    \dim_compare:nT { \l_illustimage_minimum_width_dim > 0pt }
    {
        \dim_compare:nT { \l_illustimage_image_width_dim <  \l_illustimage_minimum_width_dim }
        {
			\dim_set_eq:NN \l_illustimage_image_width_dim \l_illustimage_minimum_width_dim
		}
	}    
    \dim_set:Nn \l_illustimage_text_width_dim { \linewidth - \l_illustimage_image_width_dim - \l_illustimage_gap_dim }	
    \hbox_set:Nn \l_text_box
    {
        \begin{minipage}{\l_illustimage_text_width_dim}
            \g_common_text_style\l_illustimage_textstyle_tl #6
        \end{minipage}
    }
	% restore image & text
    \illustimage_put:
    \bool_if:NT \l_illustimage_broad_bool
    {
        \bool_if:NT \g_column_vartwo_bool
        { 
			\end{adjustwidth} 
		}
    }
    \bool_set_false:N \in_illustimage_bool
    \group_end:
}

\cs_new:Nn \illustimage_put:
{
    \str_case:Vn \l_illustimage_position_tl 
    {
        { left } { \illustimage_put_left: }
        { right } { \illustimage_put_right: }
    }
}

\cs_new:Nn \illustimage_put_left:
{
    \bool_if:NTF \l_illustimage_first_bool
    {
        \object_skip_before:n {\l_illustimage_first_skip}
    }{
        \object_skip_before:n {\l_illustimage_before_skip}
    }
    \begin{minipage}{\linewidth} 
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_image_width_dim}
            \vspace{0pt}			
            \bool_if:NT \l_illustimage_broad_bool
            {
                \bool_if:NT \l_illustimage_flush_bool { \hfill }
            }
			\l_illustimage_image_align_tl
            \leavevmode \box_use:N \l_image_box      
            \illustimage_caption:      
        \end{minipage}
        \hfill 
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_text_width_dim}
            \vspace{0pt}
            \begin{minipage}{\linewidth}        
                \vspace{\l_illustimage_voffset_skip}
                \box_use:N \l_text_box        
            \end{minipage}
            \vspace{0pt}
        \end{minipage}        
    \end{minipage}
    \object_skip_after:n {\l_illustimage_after_skip}
}

\cs_new:Nn \illustimage_put_right:
{
    \bool_if:NTF \l_illustimage_first_bool
    {
        \object_skip_before:n {\l_illustimage_first_skip}
    }{
        \object_skip_before:n {\l_illustimage_before_skip}
    }
    \begin{minipage}{\linewidth}	
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_text_width_dim}
            \vspace{0pt}
            \begin{minipage}{\linewidth}        
                \vspace{\l_illustimage_voffset_skip}
                \box_use:N \l_text_box        
            \end{minipage}
            \vspace{0pt}
        \end{minipage}
        \hfill
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_image_width_dim}			
            \vspace{0pt}			
            \bool_if:NT \l_illustimage_broad_bool
            {
                \bool_if:NT \l_illustimage_flush_bool { \hfill }
            }
			\l_illustimage_image_align_tl
            \leavevmode \box_use:N \l_image_box
            \illustimage_caption:
        \end{minipage}
    \end{minipage}
    \object_skip_after:n {\l_illustimage_after_skip}
}

\cs_new:Nn \illustimage_caption:
{
    \bool_if:NT \l_illustimage_showfilename_bool
    {
        \legend{\exp_args:No \tl_to_str:N \l_illustimage_label }
    }
    \tl_if_empty:NF \l_illustimage_caption
    {
		\captionstyle{\l_illustimage_caption_align_tl}
		\bool_if:NF \l_illustimage_caption_ignore_bool
		{
			\bool_if:NTF \l_illustimage_legend_bool
			{				
				\legend{\l_illustimage_caption}
			}{
				\imgcaption{\l_illustimage_caption}
				\label{\l_illustimage_label}
			}
		}
    }
}

% as environment
\NewEnviron{IllustratedImage}[1]{ \illustimage{ #1 }{ \BODY } }
\NewDocumentEnvironment {IllustImage} { s t^ O{} m d() }
{
    \IfBooleanT {#1} { 
        \exp_args:No \IllustImageSetup{ \l_illustimage_star_tl }
    }
    \IfBooleanT {#2} { 
        \IllustImageSetup{first=true} 
    }
    %\IfValueT {#3} { 
        \IllustImageSetup{#3} 
    %}
    \IfValueT {#5} { 
        \tl_set:Nn \l_illustimage_caption {#5} 
    }
    \IllustratedImage{#4}
}{
    \endIllustratedImage
}

% as environment for symbol
\NewDocumentEnvironment { IllustSymbol } { O{} m }
{
    \IllustImageSetup{frame=false, voffset=0.75ex, valign=m, #1} 
    \IllustratedImage{#2}
}{
    \endIllustratedImage
}

% as environment for itemize
\NewEnviron{IllustratedItemize}[1]{
    \illustimage{#1}{
        \begin{itemize}
        \BODY
        \end{itemize}
    }
}
\NewDocumentEnvironment { IllustItem } { o m }
{
    \IfValueT{#1} { \IllustImageSetup{#1} }
    \IllustratedItemize{#2}
}{
    \endIllustratedItemize
}

% as environment for enumerate
\NewEnviron{IllustratedEnumerateStart}[1]{
    \illustimage{#1}{
        \begin{enumerate}[series=IlluEnum, leftmargin=1.5em]
        \BODY
        \end{enumerate}
    }
}
\NewEnviron{IllustratedEnumerateContinue}[1]{
    \illustimage{#1}{
        \begin{enumerate}[series=IlluEnum, resume=IlluEnum, leftmargin=1.5em]
        \BODY
        \end{enumerate}
    }
}
\NewDocumentEnvironment { IllustEnum } { s t^ o m }
{
    \IfBooleanT {#1} 
	{
        \IllustImageSetup{first=true}
        \exp_args:No \IllustImageSetup{ \l_illustimage_enum_tl }
    }
    \IfBooleanT {#2} 
	{
        \exp_args:No \IllustImageSetup{ \l_illustimage_star_tl }
    }
    \IfValueT {#3} 
	{ 
        \IllustImageSetup{#3} 
    }
    \IfBooleanTF{#1}
    {
        \IllustratedEnumerateStart{#4}
    }{
        \IllustratedEnumerateContinue{#4}
    }
}{
    \IfBooleanTF{#1}
    {
        \endIllustratedEnumerateStart
    }{
        \endIllustratedEnumerateContinue
    }
}

\keys_define:nn { marginimage }
{
    scale         .tl_set:N = \l_marginimage_scale,
    voffset       .skip_set:N = \l_marginimage_voffset,
    showfilename  .bool_set:N = \l_marginimage_showfilename_bool,
}

\NewDocumentCommand \MarginImageSetup { m }
{
    \keys_set:nn { marginimage } { #1 }
}

\MarginImageSetup{
    scale=1,
    voffset=2ex,
    showfilename=false
}

\marginparmargin{left}

\NewDocumentCommand \marginimage { s O{} m }
{
    \IfBooleanT {#1} { \newpage }
    \group_begin:
    \MarginImageSetup{#2}
     \marginpar{
        \vspace{\l_marginimage_voffset}
         \includegraphics[scale=\l_marginimage_scale]{#3}
         \bool_if:NT { \l_marginimage_showfilename_bool}
            { \newline \tiny \tl_to_str:n { #3 } }
     }
    \group_end:
}

% \lineimg[]{foo} -------------------------------------------------------------
\keys_define:nn { lineimg }
{
    scale      .tl_set:N = \l_lineimg_scale,
    raise      .tl_set:N = \l_lineimg_raise,
    showfilename  .bool_set:N  = \l_lineimg_showfilename_bool
}

\NewDocumentCommand \LineImageSetup { m }
{
    \keys_set:nn { lineimg } { #1 }
}

\LineImageSetup{
    scale=1,
    raise=-.25ex,
    showfilename=false
}

\NewDocumentCommand \img { O { \l_lineimg_raise } m }
{
    \raisebox{#1}{
        \,\includegraphics[scale=\l_lineimg_scale]{#2}\,
    }
    \bool_if:NT { \l_lineimg_showfilename_bool}
    {
        \group_begin:
        \allowbreak \tiny \tl_to_str:n { #2 }
        \group_end:
    }
}

\cs_set_eq:NN \lineimg \img

\NewDocumentCommand \listimg { m }
{
    \par\img[0pt]{#1}
}

% \settable[]{ } ------------------------------------

\cs_new:Npn \table_footnotestyle:n #1
{
    \renewcommand\thefootnote{ \use:c {#1} {footnote} }
    \renewcommand\thempfootnote{ \use:c {#1} {mpfootnote} }
}

\keys_define:nn { table }
{
    beforeskip    	.skip_set:N = \l_table_before_skip,
    afterskip     	.skip_set:N = \l_table_after_skip,
    float         	.bool_set:N = \l_table_float_bool,
	float-placement	.tl_set:N	= \l_image_float_placement_tl,
    align         	.tl_set:N 	= \l_table_align_tl,
    landscape     	.bool_set:N = \l_table_landscape_bool,
    caption       	.tl_set:N 	= \l_table_caption_tl,
    label         	.tl_set:N 	= \l_table_label_tl,
    legend        	.bool_set:N = \l_table_legend_bool,
    font          	.tl_set:N 	= \l_table_font_tl,
    fontsize      	.tl_set:N 	= \l_table_fontsize_tl,
    hook          	.tl_set:N 	= \l_table_hook_tl,
    footnote      	.tl_set:N 	= \l_table_footnote,
    footnotestyle 	.code:n 	= { \table_footnotestyle:n {#1} }, % footnotestyle=fnsymbol
    stretch       	.tl_set:N 	= \l_table_stretch_tl,
    norowcolor    	.bool_set:N	= \l_table_norowcolor_bool,
	star		  	.tl_set:N 	= \l_table_star_tl,
	vbar		  	.tl_set:N 	= \l_table_vbar_tl,
	protrude		.dim_set:N  = \l_table_protrude_dim % valid only at vartwo
}

\NewDocumentCommand \TableSetup { m }
{
    \keys_set:nn { table } { #1 }
	\exp_args:NNx \def\fps@table { \l_image_float_placement_tl }
}

\TableSetup{
    beforeskip=0pt,
    afterskip=0pt,
    float=false,
	float-placement=tbh,
    landscape=false,
    legend=false,
    font=\rmfamily,
    fontsize=\small,
    footnotestyle=arabic,
    stretch=1,
    norowcolor=false,
	star={norowcolor},
	protrude=0pt
}

% \placetable*|[options](caption)<footnote>{tabular}
\NewDocumentCommand \placetable { s t| O{} d() d<> m }
{
    \group_begin:	
    \IfBooleanT{ #1 }
	{
		\exp_args:No \TableSetup{ \l_table_star_tl }
	}
	\IfBooleanT { #2 }
	{
		\exp_args:No \TableSetup{ \l_table_vbar_tl}
	}
    \TableSetup{ #3 }
    \IfValueT{ #4 } { \tl_set:Nn \l_table_caption_tl {#4} }
    \IfValueT{ #5 } { \tl_set:Nn \l_table_footnote {#5} }
    \bool_if:NTF \l_table_norowcolor_bool 
    { 
        \rowcolors{1}{white}{white}
    }{
        \rowcolors{1}{white}{backgray}
    }
	\dim_compare:nT { \l_table_protrude_dim > 0pt }
	{
		\begin{IfVartwoEnlarge}[-\l_table_protrude_dim]
	}
    \hbox_set:Nn \l_text_box
    {
        \tl_set:NV \arraystretch \l_table_stretch_tl		
        \l_table_font_tl
        \l_table_fontsize_tl
        \l_table_hook_tl
        #6
    }
    \bool_if:NTF \l_table_float_bool
    {
        \begin{table}
        \table_put:
        \end{table}
    }{
        \object_skip_before:n {\l_table_before_skip}
        \table_put:
        \object_skip_after:n {\l_table_after_skip}
    }
	\dim_compare:nT { \l_table_protrude_dim > 0pt }
	{
		\end{IfVartwoEnlarge}
	}
    \group_end:
}

\cs_new:Nn \table_put:
{
    \bool_if:NTF \l_table_landscape_bool
    { 
        \table_put_landscape: 
    }{ 
        \table_put_portrait: 
    }
}

\cs_new:Nn \table_put_portrait:{
	
    \dim_compare:nTF { \g_protrude_dim > 0pt }
    {
        \dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_text_box }
        \object_locate:N \l_tmpa_dim
    }{
        \dim_set:Nn \l_tmpa_dim { \linewidth }
    }	
    \begin{minipage}{\l_tmpa_dim}
        \table_caption:	
		\l_table_align_tl		
        \mbox{ \box_use:N \l_text_box }
		\table_footnote:    
	\end{minipage}
	
}

\cs_new:Nn \table_put_landscape:
{
    \dim_compare:nTF { \g_protrude_dim > 0pt }
    {
        \dim_set_towidth:Nn \l_tmpb_dim { \box_use:N \l_text_box  }
        \dim_set_toheight:Nn \l_tmpa_dim { \box_use:N \l_text_box  }
        \object_locate:N \l_tmpa_dim
    }{
        \dim_set:Nn \l_tmpb_dim { \linewidth }
    }
    \rotatebox{-90}{
        \begin{minipage}{\l_tmpb_dim}            
            \table_caption:
			\l_table_align_tl		
        	\mbox{ \box_use:N \l_text_box }
			\table_footnote:
        \end{minipage}
    }
}

\cs_new:Nn \table_caption:
{
    \tl_if_empty:NF \l_table_caption_tl
    {
        \bool_if:NTF \l_table_legend_bool
        {
            \legend{\l_table_caption_tl}
        }{
            \tabcaption{\l_table_caption_tl}
			\tl_if_empty:NF \l_table_label_tl
			{
	            \label{\l_table_label_tl}
			}
        }
    }
}

\cs_new:Nn \table_footnote:
{
    \tl_if_empty:NF \l_table_footnote
    {
        \vspace{-.5\baselineskip}\par
        \begin{minipage}{\linewidth}
            \setfootnoterule{0pt}{0pt}{0pt}
            \l_table_footnote			
        \end{minipage}
    }
}

\NewEnviron{PlaceTable}[1][]{ \placetable[#1]{\BODY} }
\NewDocumentEnvironment { Table } { s t| o d() d<> }
{
	\IfBooleanT{ #1 }
	{
		\exp_args:No \TableSetup{ \l_table_star_tl }
	}
	\IfBooleanT { #2 }
	{
		\exp_args:No \TableSetup{ \l_table_vbar_tl}
	}
    \IfValueT{ #3 } 
	{ 
		\TableSetup{#3} 
	}
    \IfValueT{ #4 } 
	{ 
		\tl_set:Nn \l_table_caption_tl {#4} 
	}
    \IfValueT {#5}  
	{ 
		\tl_set:Nn \l_table_footnote {#5} 
	}
    \PlaceTable
}{
    \endPlaceTable
}

\NewEnviron{spectable}{
    \placetable{
        %\begin{tabu}{X[lm]X[1.5lm]}
        \begin{tabularx}{\linewidth}{XX}
        \hline\BODY\hline
        \end{tabularx}
    }
}

\NewEnviron{spectablex}{
    \placetable{
        %\begin{tabu}{lX[lm]}
        \begin{tabularx}{\linewidth}{lX}
        \hline\BODY\hline
        \end{tabu}
    }
}

\NewDocumentEnvironment { SpecTable } { s o d() d<> }
{
    \IfValueT{#2} { \TableSetup{#2} }
    \IfValueT{#3} { \tl_set:Nn \l_table_caption_tl {#3} }
    \IfValueT{#4} { \tl_set:Nn \l_table_footnote {#4} }
    \IfBooleanTF{#1}{\spectablex}{\spectable}
}{
    \IfBooleanTF{#1}{\endspectablex}{\endspectable}
}

\NewEnviron{imagetableiii}{
    \placetable[stretch=1.3,font=\small,norowcolor]{        
        \begin{tabularx}{\linewidth}{XXX}
        \BODY
        \end{tabularx}
    }
}

\NewEnviron{imagetableii}{
    \placetable[stretch=1.3,font=\small,norowcolor]{
        \begin{tabularx}{\linewidth}{XXX}
        \BODY
        \end{tabularx}
    }
}

\NewDocumentEnvironment { ImageTable } { s d<> }
{
    \IfValueT{#2} { \tl_set:Nn \l_table_footnote {#2} }
    \IfBooleanTF{#1}
    {
        \imagetableii
    }{
        \imagetableiii
    }
}
{
    \IfBooleanTF{#1}
    {
        \endimagetableii
    }{
        \endimagetableiii
    }
}

\NewDocumentCommand \TableCommon { O{} }
{
    \TableSetup{#1}
    \tl_set:Nn \arraystretch {\l_table_stretch_tl}
    \l_table_font_tl
    \l_table_fontsize_tl    
}

% object utilities ------------------------------------------------------------

\NewDocumentCommand \SetObjectAlign { m }
{
    \CaptionSetup{ align-short=#1, align=#1 }
    \ImageSetup{ align=#1 }
    \TableSetup{ align=#1 }
}

\NewDocumentCommand \ShowImageFilename { s }
{
    \ImageSetup{showfilename=true}
    \IllustImageSetup{showfilename=true}
    \MarginImageSetup{showfilename=true}
    \IfBooleanT{#1} { 
        \LineImageSetup{showfilename=true} 
    }
}

\NewDocumentCommand \HideImageFilename { }
{
    \ImageSetup{showfilename=false}
    \IllustImageSetup{showfilename=false}
    \MarginImageSetup{showfilename=false}
    \LineImageSetup{showfilename=false}
}

\NewDocumentCommand \imagescale { m o }
{
    \IfNoValueTF {#2}
    {
        \tl_set:Nn \l_image_scale_tl {#1}
        \tl_set:Nn \l_illustimage_scale_tl {#1}
        \tl_set:Nn \l_lineimg_scale {#1}
    }{
        \str_case:nn {#2}
        {
            {\image}        { \tl_set:Nn \l_image_scale_tl {#1} }
            {\illustimage}  { \tl_set:Nn \l_illustimage_scale_tl {#1} }
            {\lineimg}      { \tl_set:Nn \l_lineimg_scale {#1} }
        }
    }
}

\NewDocumentEnvironment {ImageScale} { m m }
{
    \group_begin:
    \imagescale{#1}{#2}
}{
    \group_end:
}

\ior_new:N \l_txt_io

\NewDocumentCommand \MakeAlbum { s O {0.5} m }
{   
    \int_zero:N \l_tmpa_int
    \ImageSetup{scale=#2, fitline=true}
    \IfBooleanTF{#1}
    { 
        \ImageSetup{showfilename=false}        
    }{ 
        \ImageSetup{showfilename=true} 
        \CaptionSetup{align=\raggedright}
    }
    \ior_open:Nn \l_txt_io { #3 }
    \ior_map_inline:Nn \l_txt_io
    {
        \tl_set:Nn \l_tmpa_tl { ##1 }
        \tl_trim_spaces:N \l_tmpa_tl
        \tl_if_empty:NF { \l_tmpa_tl }
        {            
            \int_incr:N \l_tmpa_int
            \pdfbookmark[1]{\tl_to_str:N \l_tmpa_tl}{\int_use:N \l_tmpa_int}
            \image{\l_tmpa_tl}\par
        }
    }
    \ior_close:N \l_txt_io
}

% term, index, list * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% index  ----------------------------------------------------------------------

\newcommand\indexfont{\small}
\addtodef{\printindex}{\indexfont}{}
\setlength\indexcolsep{2em}

\NewDocumentCommand \BookmarkIndexHead {}
{
    \int_new:N \l_index_anchor_int
    \ProvideDocumentCommand \lettergroup {m}
    {
        \int_incr:N \l_index_anchor_int
        \pdfbookmark[1]{##1}{\int_use:N \l_index_anchor_int}
        \par\textbf{##1}\nopagebreak
    }
}
% Use \IndexingEnable to enable the indexing function of term-related macros including \term.

\NewDocumentCommand \IndexingEnable { s }
{
    \makeindex    
    \bool_gset_true:N \l_term_index_bool
    \bool_gset_true:N \l_terms_index_bool
    \IfBooleanT{ #1 }{ \BookmarkIndexHead }
}
\NewDocumentCommand \IndexingDisable {}
{
    \bool_gset_false:N \l_term_index_bool
    \bool_gset_false:N \l_terms_index_bool
}

% \term*|[index position]{\LaTeX}
\tl_new:N \g_term_options_tl
\keys_define:nn { term }
{
    color       .tl_set:N = \l_term_color_tl,
    font        .tl_set:N = \l_term_font_tl,
    star        .tl_set:N = \l_term_star_tl,
    vbar        .tl_set:N = \l_term_vbar_tl,
    index       .bool_set:N = \l_term_index_bool,
	link		.bool_set:N = \l_term_link_bool % link to glossary
}
\NewDocumentCommand \TermInitialize { m }
{
    \keys_set:nn { term }{ #1 }
}
\TermInitialize{
    color = black,
    index = false 
}
\NewDocumentCommand \TermSetup { o m }
{
	\IfValueTF { #1 }
	{
		\NewTerm*{ #1 }{ #2 }
	}{
    	\tl_set:Nn \g_term_options_tl { #2 }
	}
}

\NewDocumentCommand \NewTerm { s m m }
{
    \IfBooleanTF{#1}{
        \RenewDocumentCommand 
    }{
        \NewDocumentCommand 
    } #2 { s t| o m o }
    {
        \keys_set:nn { term }{ #3 }
        \exp_args:Nno \keys_set:nn { term }{ \g_term_options_tl }        
        \IfBooleanT{ ##1 }
        {
            \exp_args:Nno \keys_set:nn { term }{ \l_term_star_tl }
        }
        \IfBooleanTF{ ##2 }
        {
            \exp_args:Nno \keys_set:nn { term }{ \l_term_vbar_tl }
        }
        \bool_if:NT \l_term_index_bool
        {
            \IfValueTF{ ##3 }
            {
                \index{##3@##4}                
            }{
				\IfValueTF { ##5 }
				{
					\index{##5!##4}
				}{
                	\index{##4}
				}
            }
        }
		\bool_if:NTF \l_term_link_bool
		{
        	\textcolor{ \l_term_color_tl }{ \l_term_font_tl \hyperlink{##4}{##4} }
		}{
        	\textcolor{ \l_term_color_tl }{ \l_term_font_tl ##4 }
		}
    }    
}
\NewDocumentCommand \RenewTerm { m m }
{
    \NewTerm*{ #1 }{ #2 }
}

\NewTerm{\term}{
    font = {},
    index = true,
    star = { font=\itshape }
}

\NewTerm{\ui} % user interface
{
    font = \sffamily\bfseries,
    color = darkgray,
    index = false,
    star = { index=true }
}
\NewTerm{\mi} % machine interface
{
    font = \sffamily\mdseries,
    index = false,
    star = { index=true }
}

\NewDocumentCommand \menu { s o o m m }
{
    \IfBooleanTF{ #1 }
    {
        \IfValueT{ #2 }{ \ui*{#2} ~ > ~ }
        \IfValueT{ #3 }{ \ui*{#3} ~ > ~ }
        \ui*{#4} ~ > ~ \ui*{#5}
    }{
        \IfValueT{ #2 }{ \ui{#2} ~ > ~ }
        \IfValueT{ #3 }{ \ui{#3} ~ > ~ }
        \ui{#4} ~ > ~ \ui{#5}
    }
}

% lists  -------------------------------------------------------
\keys_define:nn { hzlist }
{
    enumerate   .tl_set:N = \g_hzlist_enumerate_style,
    itemize     .tl_set:N = \g_hzlist_itemize_style
}

\NewDocumentCommand \SetListStyle { m }
{
    \keys_set:nn { hzlist }{ #1 }
}

\RenewDocumentEnvironment {enumerate} { s O{} }
{
    \IfBooleanTF {#1} {
        \enit@enumerate\enitdp@enumerate{enum}\thr@@{noitemsep, #2} %label=\arabic*)
    }{
        \enit@enumerate\enitdp@enumerate{enum}\thr@@{#2}
    }  
    \g_hzlist_enumerate_style
}{
    \enit@endenumerate
}

\RenewDocumentEnvironment {itemize} { s O{} }
{  
    \IfBooleanTF {#1} { 		
        \enit@itemize\enitdp@itemize{item}\thr@@{noitemsep, #2}
    }{
        \enit@itemize\enitdp@itemize{item}\thr@@{#2}
    }
    \g_hzlist_itemize_style
}{
    \enit@enditemize
}

% definition list
% \begin{terms}*|[options](base)
\tl_new:N \g_terms_options_tl
\int_new:N \l_terms_int
\tl_new:N \l_terms_marker
\tl_new:N \l_terms_marker_i
\tl_new:N \l_terms_marker_ii
\cs_new:Npn \terms_define_marker:n #1
{
    \int_zero:N \l_tmpa_int
    \clist_map_inline:nn {#1}
    {
        \int_case:nn {\l_tmpa_int}
        {
            {0} {
                 \tl_if_empty:nTF {##1}
                     { \tl_set:Nn \l_terms_marker_i {} }
                     { \tl_set:Nn \l_terms_marker_i {##1\hskip\l_terms_marker_sep_skip} }
                }
            {1} {
                 \tl_if_empty:nTF {##1}
                     { \tl_set:Nn \l_terms_marker_ii {} }
                     { \tl_set:Nn \l_terms_marker_ii {##1\hskip\l_terms_marker_sep_skip} }
                }
         }
        \int_incr:N \l_tmpa_int
    }
}
\tl_set:Nn \l_terms_marker {
    \int_compare:nT { \@listdepth = 1 }  { \l_terms_marker_i }
    \int_compare:nT { \@listdepth = 2 }  { \l_terms_marker_ii }
}

\keys_define:nn { terms }
{
    label-type  .tl_set:N = \l_terms_label_type_tl,
    offset      .skip_set:N = \l_terms_offset_skip,
    marker      .code:n = { \terms_define_marker:n {#1} },
    marker-sep  .skip_set:N = \l_terms_marker_sep_skip,
    enumerate   .bool_set:N = \l_terms_enumerate_bool,
    enum-marker .tl_set:N = \l_terms_enummarker_tl,
    base        .tl_set:N = \l_terms_base_tl,
    font        .tl_set:N = \l_terms_font_tl,
    color       .tl_set:N = \l_terms_color_tl,
    delimiter   .tl_set:N = \l_terms_delimiter_tl,
    label-width .dim_set:N = \l_terms_label_width_dim,
    label-sep   .skip_set:N = \l_terms_label_sep_skip,
	item-indent .dim_set:N = \l_terms_item_indent_dim,
	left-margin .dim_set:N = \l_terms_left_margin_dim,
    index       .bool_set:N = \l_terms_index_bool,
	anchor		.bool_set:N = \l_terms_anchor_bool, % for glossary
    top-sep     .skip_set:N = \l_terms_top_sep_skip,
    item-sep    .skip_set:N  = \l_terms_item_sep_skip,
    before-list .tl_set:N = \l_terms_before_list_tl,
    after-list  .tl_set:N = \l_terms_after_list_tl,
    star        .tl_set:N = \l_terms_star_tl,
    vbar        .tl_set:N = \l_terms_vbar_tl
}
\NewDocumentCommand \TermsInitialize { m }
{
    \keys_set:nn { terms }{ #1 }    
}
\TermsInitialize{
    label-type = default,
    offset = 0em,
    marker = {{},\textbullet},
    marker-sep = 0.5em,
    base = MM,
    font = \bfseries,
    color = black,
    delimiter = :\hfill,	
    label-sep = 0.5em,
	left-margin = 0pt,
    star = { item-sep=0ex },
    vbar = { delimiter=\hfill },
    enum-marker = { \int_use:N \l_terms_int)\hskip\l_terms_marker_sep_skip }
}

\NewDocumentCommand \TermsSetup { o m }
{
	\IfValueTF { #1 }
	{
		\NewTerms*{ #1 }{ #2 }
	}{
    	\tl_gset:Nn \g_terms_options_tl { #2 }
	}
}
\cs_new:Npn \terms_label_anchor:n #1
{
	\bool_if:NTF \l_terms_anchor_bool
	{
		\hypertarget{#1}{#1}
	}{
		#1
	}
}
\cs_new:Npn \terms_label_default:n #1
{
    \int_gincr:N \l_terms_int
    \bool_if:NT \l_terms_index_bool { \index{#1} }
    \group_begin:
        \color{\l_terms_color_tl}
        \l_terms_marker
        \l_terms_font_tl 
		\terms_label_anchor:n { #1 }
    \group_end:
    \l_terms_delimiter_tl
}
\cs_new:Npn \terms_label_newline:n #1
{
    \int_gincr:N \l_terms_int
    \bool_if:NT \l_terms_index_bool { \index{#1} }
    \parbox[b]{\labelwidth}{
        \makebox[0pt][l]{
            \color{\l_terms_color_tl}
            \l_terms_marker
            \l_terms_font_tl 
			\terms_label_anchor:n { #1 }
            \l_terms_delimiter_tl
        }
        \newline
    }
}
\cs_new:Npn \terms_label_multiline:n #1
{
    \int_gincr:N \l_terms_int
    \bool_if:NT \l_terms_index_bool { \index{#1} }
    \hbox_set:Nn \l_tmpa_box 
    {
        \parbox[t]{\labelwidth}{
            \raggedright
            \color{\l_terms_color_tl}
            \l_terms_font_tl 
			\terms_label_anchor:n { #1 }
        }
    }
    \hbox_set:Nn \l_tmpb_box {\l_terms_font_tl A}
    \dim_set:Nn \l_tmpa_dim { \box_ht:N \l_tmpb_box }
    \raisebox{\l_tmpa_dim}{ \smash{\box_use:N \l_tmpa_box} }
}
\cs_new:Npn \terms_label_verbatim:n #1
{
    \int_gincr:N \l_terms_int
    \str_set:Nn \l_tmpa_str { #1 }
    \bool_if:NT \l_terms_index_bool { \index{\l_tmpa_str} }
    \group_begin:
        \color{\l_terms_color_tl}
        \l_terms_marker
        \l_terms_font_tl 
		\terms_label_anchor:n { \l_tmpa_str }
    \group_end:
    \l_terms_delimiter_tl
}
\cs_new:Npn \terms_label_type_set:n #1
{
    \skip_set:Nn \partopsep { 0pt }
    \skip_set_eq:NN \topsep \l_terms_top_sep_skip
    \skip_set_eq:NN \itemsep \l_terms_item_sep_skip
    \skip_set:Nn \listparindent { 0pt }
    \str_case:on { #1 }
    {
        { default }{
            \dim_set_towidth:Nn \labelwidth { \l_terms_marker\l_terms_font_tl\l_terms_base_tl\l_terms_delimiter_tl }
            \cs_set_eq:NN \makelabel \terms_label_default:n
        }
        { newline }{
            \dim_set_towidth:Nn \labelwidth { \l_terms_marker }
            \skip_set_eq:NN \partopsep \hzparskip
            \cs_set_eq:NN \makelabel \terms_label_newline:n
        }
        { multiline }{
            \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            \cs_set_eq:NN \makelabel \terms_label_multiline:n
        }
        { verbatim }{
            \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            \cs_set_eq:NN \makelabel \terms_label_verbatim:n
        }
    }
    \skip_set_eq:NN \labelsep \l_terms_label_sep_skip
   	\dim_set:Nn \leftmargin { \labelwidth+\labelsep }
    \int_compare:nT { \@listdepth = 1 }
    {
        \addtolength\leftmargin{ \l_terms_offset_skip } 
    }	
	\dim_compare:nT { \l_terms_left_margin_dim > 0pt }
	{
		\dim_set:Nn \leftmargin \l_terms_left_margin_dim
	}
	\dim_compare:nT { \l_terms_item_indent_dim > 0pt }
	{
		\dim_set:Nn \itemindent \l_terms_item_indent_dim
	}
}

\NewDocumentCommand \NewTerms { s m m }
{
    \IfBooleanTF{ #1 }{
        \RenewDocumentEnvironment
    }{
        \NewDocumentEnvironment
    }{ #2 }{ s t| O{} d() }
    {
        \keys_set:nn { terms }{ #3 }
        \exp_args:Nno \keys_set:nn { terms }{ \g_terms_options_tl }
        \IfBooleanT{ ##1 }
        {
            \exp_args:Nno \keys_set:nn { terms }{ \l_terms_star_tl }        
        }
        \IfBooleanT{ ##2 }
        {
            \exp_args:Nno \keys_set:nn { terms }{ \l_terms_vbar_tl }
        }
        \l_terms_before_list_tl
        \begin{list}{}
        {
            \keys_set:nn { terms }{ ##3 }
            \bool_if:NT \l_terms_enumerate_bool
            {
                \tl_set:Nn \l_terms_marker_i { \l_terms_enummarker_tl }
                \int_gzero:N \l_terms_int
            }
            \IfValueT{ ##4 }
            {
                \tl_set:Nn \l_terms_base_tl { ##4 }
            }
            \terms_label_type_set:n { \l_terms_label_type_tl }
        }
    }{
        % \cs_set_eq:NN \uitem \item
        % \cs_set_eq:NN \mitem \item
        \end{list}
        \l_terms_after_list_tl
    }
    
}

\NewDocumentCommand \RenewTerms { m m }
{
    \NewTerms*{ #1 }{ #2 }
}


\NewTerms{terms}
{
    %index = false
}
\NewTerms{UI}
{
    font = \sffamily\bfseries,
    color = darkgray,
    %index = false  
}
\NewTerms{Symbols}
{
    label-type = multiline,
    label-width = 3em,
    index = false,
    %before-list = \RuleBox,
    %after-list = \endRuleBox,
    delimiter = \hfill,
    item-sep = 1ex, 
}
\NewDocumentCommand \imgitem { m }
{
    \item[\lineimg{#1}]
}

\cs_new:Npn \terms_label_tmp:n #1
{
    \dim_set_towidth:Nn \l_tmpa_dim {#1}
    \dim_set_towidth:Nn \l_tmpb_dim {\l_tmpa_tl}
    \int_compare:nT {\l_tmpa_dim > \l_tmpb_dim}
    {
        \tl_gset:Nn \l_tmpa_tl {#1}
    }
}
\NewDocumentEnvironment { termstmp } {}
{
    \begin{list}{}
    {
        \tl_gset:Nn \l_tmpa_tl {M}
        \cs_set_eq:NN \makelabel \terms_label_tmp:n
    }
}{
    \end{list}
}
\NewDocumentCommand \alignterms { o m }
{
    \hbox_set:Nn \l_tmpa_box
    {
        \begin{minipage}{\linewidth}
        \begin{termstmp} #2 \end{termstmp}
        \end{minipage}
    }
    \begin{terms}[base=\l_tmpa_tl, #1]
    #2
    \end{terms}
}
\NewEnviron{Terms}[1][]{ \alignterms[#1]{\BODY} }


\tl_new:N \l_symbol_options
\NewDocumentCommand \SymbolsSetup { m }
{
    \tl_set:Nn \l_symbol_options {#1}
}

% option list
\int_new:N \l_opt_cnt_int
\cs_new_nopar:Nn \opt_selected: { ☑ } 
\cs_new_nopar:Nn \opt_unselected: { ☐ }
\cs_new_nopar:Nn \opt_label:
{
    \int_gincr:N \l_opt_cnt_int
    \clist_if_in:NoTF \l_tmpa_clist {\int_use:N \l_opt_cnt_int}
    {
		\opt_selected:
	}{
		\opt_unselected:
	}
}

\NewDocumentEnvironment { options } { s O{} }
{
    \clist_set:Nn \l_tmpa_clist { #2 }
    \int_zero:N \l_opt_cnt_int
    \begin{list} {}
    {
        \IfValueT {#1} { \tightlist }
        \cs_set_eq:NN \makelabel \opt_label:
    }
}{
    \end{list}
}

% callout list
\int_new:N \l_callout_int

\NewDocumentCommand \calloutno {}
{
    \int_to_arabic:n { \l_callout_int }
}

\keys_define:nn { callout }
{
    beforeskip  .skip_set:N = \l_callout_before_skip,
    afterskip   .skip_set:N = \l_callout_after_skip,
    rule        .bool_set:N = \l_callout_rule_bool,
    column      .int_set:N = \l_callout_column_int,
    font        .tl_set:N = \l_callout_font_tl,
    label       .tl_set:N = \l_callout_label_tl,
    tab         .bool_set:N = \l_callout_tab_bool,
    space       .skip_set:N = \l_callout_space_skip,
}

\NewDocumentCommand \CalloutSetup {m}
{
    \keys_set:nn { callout } {#1}
}

\CalloutSetup{
    beforeskip=.25\baselineskip,
    afterskip=.75\baselineskip,
    column=3,
    font=\small,
    label={\makebox[1.25em]{\hfill\calloutno)}\enspace},
    tab=true,
    space=0.25em
}
%label=\cirnum{\calloutno}

\cs_new:Nn \callout_item_tab:
{
    \int_gincr:N \l_callout_int
    \int_compare:nTF { \l_callout_int > 1 }
    {
        \int_set:Nn \l_tmpa_int {\int_mod:nn {\l_callout_int} {\l_callout_column_int} }
        \int_compare:nTF { \l_tmpa_int = 1 }{\newline}{\tab}
    }{
        \unskip
    }
    \l_callout_label_tl
}

\cs_new:Nn \callout_item_space:
{
    \int_gincr:N \l_callout_int
    \int_compare:nT { \l_callout_int > 1 } {\hskip\l_callout_space_skip}
    \l_callout_label_tl
}

\NewDocumentEnvironment {callout} { s o }
{
    \bool_if:NT \l_callout_rule_bool 
    { 
        \object_skip_before:n {\l_callout_before_skip}
        \begin{RuleBox} 
    }
    %\setfootnoterule{0pt}{0pt}{0pt}
    \l_callout_font_tl    
    \IfBooleanTF {#1}
    {        
        \begin{calloutenum}
        %\tightlist	
    }{
        \begin{flushleft}
        \IfValueT {#2} { \int_set:Nn \l_callout_column_int {#2} }
        \NumTabs {\l_callout_column_int}
        \int_zero:N \l_callout_int
        \bool_if:NTF \l_callout_tab_bool
        { 
            \cs_set_eq:NN \item \callout_item_tab: 
        }{ 
            \cs_set_eq:NN \item \callout_item_space: 
        }
    }
}{
    \IfBooleanTF {#1} 
    { 
        \end{calloutenum}  
    }{
        \end{flushleft}
    }
    \bool_if:NT \l_callout_rule_bool 
    { 
        \end{RuleBox} 
        \object_skip_after:n {\l_callout_after_skip}
    }
}


\newlist{calloutenum}{enumerate}{1}
\setlist[calloutenum]{
	label=\arabic*),
}

\ExplSyntaxOff

\usetikzlibrary{shapes}
\usetikzlibrary{shadows}

\ExplSyntaxOn

\NewDocumentCommand\cirnumdraw{ m m m m m m m }
{
    \raisebox{#1}{\abnormalparskip{0pt}
        \tikz\node[
            circle, draw=#2, thin, inner~sep=#3,
            top~color=#4, bottom~color=#4,
            text~width=#5,
            font=#6, text~badly~centered, #2
            ]{#7};}%
}

\dim_new:N \l_cirnum_width_dim

\cs_new:Npn \cirnum_get_base_width:n #1
{
    \dim_set_towidth:Nn \l_cirnum_width_dim { \l_cirnum_font_feature\l_cirnum_font #1 }
}

\keys_define:nn {cirnum}
{
    fgcolor     .tl_set:N = \l_cirnum_fgcolor,
    bgcolor     .tl_set:N = \l_cirnum_bgcolor,
    font        .tl_set:N = \l_cirnum_font,
    fontfeature .tl_set:N = \l_cirnum_font_feature,
    base        .code:n = { \cirnum_get_base_width:n {#1} },
    sep         .dim_set:N = \l_cirnum_sep_dim,
    raise       .dim_set:N = \l_cirnum_raise_dim
}

\NewDocumentCommand \CirnumSetup {m}
{
    \keys_set:nn {cirnum} {#1}
}

\CirnumSetup{
    font=\sffamily\footnotesize\bfseries,
    fgcolor=white,
    bgcolor=black,
    sep=0.25pt,
    raise=-.5ex,
    base=9
}

%\CirnumSetup{fontfeature={\addfontfeature{LetterSpace=-3}}}

\NewDocumentCommand \cirnum { m }
{
    \cirnumdraw
        { \l_cirnum_raise_dim }
        { \l_cirnum_fgcolor }
        { \l_cirnum_sep_dim }
        { \l_cirnum_bgcolor }
        { \l_cirnum_width_dim }
        { \l_cirnum_font_feature\l_cirnum_font }
        { #1 }
}

% environments using one of bounded text boxes for admonition and reference
% BoundedBox*: without linespacing before and after
% BoundedBox|: (deprecated) the box becomes breakable when it is globally set to be unbreakable, or the other way.

\tcbuselibrary{breakable, skins, xparse}
\tcbset{enhanced}

\NewTColorBox{FrameBox}{ s }
{
    colframe=gray, colback=white,
    boxrule=0.5pt, arc=0pt, 
    boxsep=0.5ex, top=0.75ex, bottom=0.75ex, left=0.5em, right=0.5em,
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}
\NewTColorBox{LeftBarBox}{ s }
{
    before~skip=0pt, after~skip=0pt, breakable=false,
    colframe=white, colback=white, arc=0ex, boxrule=0pt,
    boxsep=0pt, top=0pt, bottom=0pt, left=1.5em, right=0em,
    borderline~west={1.5pt}{0pt}{gray}, 
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}

\NewTColorBox{RightBarBox}{ s }
{
    before~skip=0pt, after~skip=0pt, breakable=false,
    colframe=white, colback=white, arc=0ex, boxrule=0pt,
    boxsep=0pt,  top=0pt, bottom=0pt, left=3em, right=1.5em,
    borderline~east={1.5pt}{0pt}{gray}, 
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}

\NewTColorBox{ShadowBox}{ s O{} }
{
    before~skip=0pt, after~skip=0pt,
    boxrule=0.5pt, colframe=darkgray, colback=white, arc=0.5ex,
    boxsep=0.5ex, top=0.75ex, bottom=0.75ex, left=0.5em, right=0.5em,
    titlerule=0.75pt, toptitle=0.25ex, bottomtitle=0.5ex,
    colbacktitle=darkgray, coltitle=white,
    drop~fuzzy~shadow={scale=2}, fonttitle=\l_bbox_title_font_tl, title=#2, 
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}

\NewTColorBox{ShadeBox}{ s O{} }
{
    before~skip=0pt, after~skip=0pt,
    boxrule=0.75pt, colframe=white, colback=backgray, arc=0.5ex,
    boxsep=0.5ex, top=0.75ex, bottom=0.75ex, left=0.5em, right=0.5em,
    titlerule=0.75pt, toptitle=0.5ex, bottomtitle=0.5ex,
    colbacktitle=lightgray, coltitle=black,
    fonttitle=\l_bbox_title_font_tl, title=#2,
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}

\NewTColorBox{RuleBox}{ s }
{
    opacityfill=0,
    before~skip=0pt, after~skip=0pt, breakable=false,
    arc=0ex, boxrule=0pt,
    boxsep=0.25ex,  top=0.75ex, bottom=0.75ex, left=0em, right=0em,
    borderline~north={0.5pt}{0pt}{darkgray},
    borderline~south={0.5pt}{0pt}{darkgray}, 
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}

\NewTColorBox{TabBox}{ s O{} }
{
    enhanced,
    before~skip=0pt, after~skip=0pt,
    boxrule=0.5pt, colframe=gray, colback=white, arc=0.5ex,
    boxsep=.5ex, top=1.5ex, bottom=0.5ex, left=0.5em, right=0.5em,
    colbacktitle=white, coltitle=black,
    attach~boxed~title~to~top~left={xshift=.5cm, yshift=-1.75mm},
    boxed~title~style={size=minimal, enhanced, boxrule=0.25pt, colframe=white},
    fonttitle=\l_bbox_title_font_tl, title=#2, 
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}

\tl_new:N \l_bbox_style_tl
\tl_set:Nn \l_bbox_style_tl { \g_common_text_style\l_bbox_style_extra_tl }

\keys_define:nn { BoundedBox }
{
    before-skip 		.skip_set:N = \l_bbox_before_skip,
    after-skip  		.skip_set:N = \l_bbox_after_skip,
    type        		.tl_set:N = \l_bbox_type_tl,
    symbol      		.tl_set:N = \l_bbox_symbol_tl,
    signal      		.tl_set:N = \l_bbox_signal_tl,
    before-signal		.tl_set:N = \l_bbox_before_signal_tl,
    after-signal		.tl_set:N = \l_bbox_after_signal_tl,
    style       		.tl_set:N = \l_bbox_style_extra_tl,
    title-font           .tl_set:N = \l_bbox_title_font_tl,
    font        		.tl_set:N = \l_bbox_font_tl,
    font-color  		.tl_set:N = \l_bbox_font_color_tl,
    wrapping    		.bool_set:N = \l_bbox_wrapping_bool,
	breakable-default	.tl_set:N = \l_bbox_breakable_default_tl,
	breakable-adhoc		.tl_set:N = \l_bbox_breakable_adhoc_tl
}

\NewDocumentCommand \BoundedBoxInitialize { m }
{
    \keys_set:nn { BoundedBox }{ #1 }
}

\BoundedBoxInitialize {
    before-skip = 0pt,
    after-skip = 0pt,
    type = shade,
    font-color = black,
    title-font = \bfseries,
	breakable-default = true,
	breakable-adhoc = false
}

\tl_new:N \g_bounded_box_options_tl
\NewDocumentCommand \BoundedBoxSetup { o m }
{
	\IfValueTF { #1 }
	{
		\NewBoundedBox*{ #1 }{ #2 }
	}{
    	\tl_gset:Nn \g_bounded_box_options_tl { #2 }
	}
}

\cs_new:Npn \bbox_type_set:n #1
{
    \str_case:onTF { #1 }
    {
        { frame }{
            \cs_set_eq:NN \BBox \FrameBox
            \cs_set_eq:NN \endBBox \endFrameBox
        }        
        { shade }{
            \cs_set_eq:NN \BBox \ShadeBox
            \cs_set_eq:NN \endBBox \endShadeBox
        }        
        { shadow }{
            \cs_set_eq:NN \BBox \ShadowBox
            \cs_set_eq:NN \endBBox \endShadowBox
        }
        { tab }{
            \cs_set_eq:NN \BBox \TabBox
            \cs_set_eq:NN \endBBox \endTabBox
        }
        { rule }{
            \cs_set_eq:NN \BBox \RuleBox
            \cs_set_eq:NN \endBBox \endRuleBox
        }
        { LeftBar }{
            \cs_set_eq:NN \BBox \LeftBarBox
            \cs_set_eq:NN \endBBox \endLeftBarBox
        }
        { RightBar }{
            \cs_set_eq:NN \BBox \RightBarBox
            \cs_set_eq:NN \endBBox \endRightBarBox
        }
	}{}        
	{ \AdhocBoxType } % define like below
}
% \newtcolorbox{FooBox}{...} 
% \NenewBoundedBox{foo}{type=FooBox}
% \NewDocumentCommand \AdhocBoxType { }
% {
% 	\cs_set_eq:NN \BBox \FooBox
% 	\cs_set_eq:NN \endBBox \endFooBox
% }

\NewDocumentCommand \NewBoundedBox { s m m }
{
    \IfBooleanTF{ #1 }{
        \RenewDocumentEnvironment
    }{
        \NewDocumentEnvironment % *=nobottomsep|=nobreakable[options](title)
    }{ #2 }{ s t| O{} d() }
    {
        \exp_args:Nno \keys_set:nn { BoundedBox }{ \g_bounded_box_options_tl }
        \keys_set:nn { BoundedBox }{ #3 }
        \group_begin:
            \keys_set:nn { BoundedBox }{ ##3 } 
			\IfValueT { ##4 }
			{                
                \tl_set:Nn \l_bbox_signal_tl { ##4 }
			}
            \bbox_type_set:n { \l_bbox_type_tl }
            \IfBooleanF{ ##1 }{ 
                \object_skip_before:n { \l_bbox_before_skip }
            }
            \tl_if_empty:NTF \l_bbox_signal_tl    
            {
				\IfBooleanTF { ##2 }
				{
                	\begin{BBox}*
				}{
					\begin{BBox}
				}
            }{
				\IfBooleanTF { ##2 }
				{
                	\begin{BBox}*[\l_bbox_symbol_tl\l_bbox_before_signal_tl\l_bbox_signal_tl\l_bbox_after_signal_tl]
				}{
                	\begin{BBox}[\l_bbox_symbol_tl\l_bbox_before_signal_tl\l_bbox_signal_tl\l_bbox_after_signal_tl]
				}
            }
                \bool_if:NT \l_bbox_wrapping_bool { \wrappingon }
                \l_bbox_style_tl
                \l_bbox_font_tl
                \color{\l_bbox_font_color_tl}
    }{
                \end{BBox}
            \IfBooleanF{##1}{
                \object_skip_after:n { \l_bbox_after_skip }
            }
        \group_end:
    }
}

\NewDocumentCommand \RenewBoundedBox { m m }
{
    \NewBoundedBox*{ #1 }{ #2 }
}

\keys_define:nn { admonition }
{
    danger      .tl_set:N = \g_admonition_danger_tl,
    warning     .tl_set:N = \g_admonition_warning_tl,
    caution     .tl_set:N = \g_admonition_caution_tl,
    notice      .tl_set:N = \g_admonition_notice_tl,
    note        .tl_set:N = \g_admonition_note_tl,
}


\NewDocumentCommand \AdmonitionSetup { m }
{
    \keys_set:nn { admonition } {#1}
}

\AdmonitionSetup{
    danger = DANGER,
    warning = WARNING,
    caution = CAUTION,
    notice = NOTICE,
    note = NOTE
}

\NewBoundedBox{danger}{signal=\g_admonition_danger_tl, symbol={\lineimg{AlertSymbol}~}}
\NewBoundedBox{warning}{signal=\g_admonition_warning_tl, symbol={\lineimg{AlertSymbol}~}}
\NewBoundedBox{caution}{signal=\g_admonition_caution_tl, symbol={}}
\NewBoundedBox{notice}{signal=\g_admonition_notice_tl, symbol={}}
\NewBoundedBox{note}{signal=\g_admonition_note_tl, symbol={}}
\NewBoundedBox{instance}{signal={}, type=RightBar, font=\small}
\NewBoundedBox{reference}{signal={}, font=\small}


%\watermark{x=30,y=30,fontsize=90,color=red,text={...},image=foo,rotate=50}
% when both text and image are specified, the former is ignored.

\bool_new:N \l_watermark_text_type
\tl_new:N \l_watermark_text
\tl_new:N \l_watermark_image

\cs_new:Npn \watermark_set_text:n #1
{
    \tl_set:Nn \l_watermark_text {#1}
    \bool_set_true:N \l_watermark_text_type
}

\cs_new:Npn \watermark_set_image:n #1
{
    \tl_set:Nn \l_watermark_image {#1}
    \bool_set_false:N \l_watermark_text_type
}

\keys_define:nn {watermark}
{
    x         .tl_set:N = \l_watermark_x,
    y         .tl_set:N = \l_watermark_y,
    color     .tl_set:N = \l_watermark_color,
    font      .tl_set:N = \l_watermark_font,
    fontsize  .tl_set:N = \l_watermark_fontsize,
    rotate    .tl_set:N = \l_watermark_rotate,
    text      .code:n = { \watermark_set_text:n {#1} },
    image     .code:n = { \watermark_set_image:n {#1} },
    scale     .tl_set:N = \l_watermark_scale
}

\NewDocumentCommand \WatermarkSetup { m }
{
    \keys_set:nn {watermark} {#1}
}

\WatermarkSetup{
    x=20,
    y=20,
    color=backgray,
    font=\sffamily,
    fontsize=10,
    rotate=0,
    scale=1
}

\NewDocumentCommand \watermark { m }
{
    \ClearWatermark
    \WatermarkSetup {#1}
    \bool_if:NTF \l_watermark_text_type
    {
        \watermark_text: 
    }{
        \watermark_image: 
    }
}

\cs_new:Nn \watermark_text:
{
    \AddToShipoutPictureBG
    {
        \dim_set:Nn \unitlength {1mm}
        \put(\l_watermark_x, \l_watermark_y)
        {
            \rotatebox{\l_watermark_rotate}
            {
                \parbox{\paperheight}
                {
                    \color{\l_watermark_color}
                    \l_watermark_font
                    \fontsize{\l_watermark_fontsize}{10}\selectfont
                    \l_watermark_text
                }
            }
        }
    }
}

\cs_new:Nn \watermark_image:
{
    \AddToShipoutPictureBG
    {
        \dim_set:Nn \unitlength {1mm}
        \put(\l_watermark_x, \l_watermark_y)
        {
            \rotatebox{\l_watermark_rotate}
            {
                \includegraphics[scale=\l_watermark_scale]{\l_watermark_image}
            }
        }
    }
}

\NewDocumentCommand \ClearWatermark {}
{
    \ClearShipoutPictureBG
}

\int_new:N \l_thumbindex_int
\int_new:N \l_thumbindex_origin
\int_new:N \l_thumbindex_toffset
\int_new:N \l_thumbindex_boffset
\int_new:N \l_thumbindex_height_int
\int_new:N \l_thumbindex_interval
\int_new:N \l_thumbindex_x
\int_new:N \l_thumbindex_y
\tl_new:N \l_thumbindex_label
\bool_new:N \l_thumbindex_vertical_bool

\keys_define:nn { thumbindex }
{
    xoffset   .dim_set:N = \l_thumbindex_xoffset,
    toffset   .code:n = { \thumbindex_origin:n {#1} },
    boffset   .code:n = { \int_set:Nn \l_thumbindex_boffset { \fp_to_int:n { \dim_to_decimal_in_unit:nn {#1} {1mm} } } },
    interval  .code:n = { \int_set:Nn \l_thumbindex_interval { \fp_to_int:n { \dim_to_decimal_in_unit:nn {#1} {1mm} } } },
    width     .dim_set:N = \l_thumbindex_width,
    height    .dim_set:N = \l_thumbindex_height,
    fgcolor   .tl_set:N = \l_thumbindex_fgcolor,
    bgcolor   .tl_set:N = \l_thumbindex_bgcolor,
    style     .tl_set:N = \l_thumbindex_style,
    content   .tl_set:N = \l_thumbindex_content,
}

\cs_new:Npn \thumbindex_origin:n #1
{
    \int_set:Nn \l_thumbindex_toffset { \fp_to_int:n { \dim_to_decimal_in_unit:nn {#1} {1mm} } }
    \int_set:Nn \l_thumbindex_origin { \fp_to_int:n { \dim_to_decimal_in_unit:nn {\paperheight} {1mm} } }
    \int_sub:Nn \l_thumbindex_origin { \l_thumbindex_toffset }
}

\NewDocumentCommand \ThumbIndexSetup { m }
{
    \keys_set:nn { thumbindex } { #1 }
    \int_set:Nn \l_thumbindex_x { \fp_to_int:n { \dim_to_decimal_in_unit:nn {\paperwidth} {1mm} } }
    \int_sub:Nn \l_thumbindex_x { \fp_to_int:n { \dim_to_decimal_in_unit:nn {\l_thumbindex_width} {1mm} } }
    \int_add:Nn \l_thumbindex_x { \fp_to_int:n { \dim_to_decimal_in_unit:nn {\l_thumbindex_xoffset} {1mm} } }
    \int_set:Nn \l_thumbindex_height_int { \fp_to_int:n { \dim_to_decimal_in_unit:nn {\l_thumbindex_height} {1mm} } }
    \tl_set:Nn \l_thumbindex_label
    {
        \colorbox{\l_thumbindex_bgcolor}{
            \parbox[c][\l_thumbindex_height]{\l_thumbindex_width}{
                \color{\l_thumbindex_fgcolor}
                \l_thumbindex_style \l_thumbindex_content
            }
        }
    }
    \renewcommand\chaptermark[1]{\markboth{##1}{}\thumbindex}
}

\NewDocumentCommand \thumbindex {}
{
    \ClearWatermark
    \int_set:Nn \l_thumbindex_y { \l_thumbindex_origin - (\l_thumbindex_height_int + \l_thumbindex_interval) * \l_thumbindex_int }
    \int_compare:nTF { \l_thumbindex_y < \l_thumbindex_boffset } {
        \int_set:Nn \l_thumbindex_y { \l_thumbindex_origin }
        \int_zero:N \l_thumbindex_int
    }{
        \int_incr:N \l_thumbindex_int
    }
    \watermark{x=\l_thumbindex_x, y=\l_thumbindex_y, text=\l_thumbindex_label}
}
\let\ClearThumbIndex\ClearWatermark

% Troubleshooting

\tl_new:N \ProblemListName
\newlistof{listofproblems}{lop}{\ProblemListName}
\newlistentry{problemsection}{lop}{0}
\newlistentry{problem}{lop}{1}
\setcounter{lopdepth}{2}
\renewcommand\cftproblemsectionfont{\bfseries}
\renewcommand\cftproblemsectionpagefont{\bfseries}
\renewcommand{\cftproblemsectiondotsep}{2000}
\renewcommand{\cftproblemdotsep}{5}
\cftsetindents{problem}{2.5em}{0em}

\keys_define:nn { problem }
{
    name  .tl_set:N = \ProblemListName,
    style  .code:n = { \renewcommand\@lopmaketitle{#1} }
}

\NewDocumentCommand \problemsection { m }
{
    \section{#1}
    \addcontentsline{lop}{problemsection}{#1}
}

\NewDocumentCommand \problem { s m }
{
    \IfBooleanTF {#1}
    { 
        \subsection*{#2} 
    }{ 
        \subsubsection*{#2} 
    }
    \addcontentsline{lop}{problem}{#2}
}

\NewDocumentCommand \ProblemSetup { m }
{
    \keys_set:nn { problem } { #1 }
}

\ProblemSetup{
    name = {Problems},
    style = \section*{\ProblemListName}
}

% miscellaneous utilities * * * * * * * * * * * * * * * * * * * * * * * * *

\keys_define:nn { finalizer }
{	
	final	.tl_set:N = \l_finalizer_final_tl,
	draft 	.tl_set:N = \l_finalizer_draft_tl
}

\NewDocumentCommand \FinalizerSetup { m }
{
	\keys_set:nn { finalizer }{ #1 }
}

\NewDocumentCommand \FinalizerOn {}
{
	\tl_use:N \l_finalizer_final_tl
}

\NewDocumentCommand \FinalizerOff {}
{
	\tl_use:N \l_finalizer_draft_tl
}

\FinalizerSetup{
	final = {\HideImageFilename\HidePending},
	draft = {\ShowImageFilename*\ShowPending}
}

\NewDocumentEnvironment { footnotes } {}
{
    \begin{enumerate}[label=\textsuperscript{\arabic*}, labelsep=0pt]
    \tightlist
    \footnotesize

}{
    \end{enumerate}
}

\NewDocumentCommand \EnlargePage { O{\baselineskip} }
{
    \enlargethispage{#1}
}

\NewDocumentCommand \pageframe { O{1ex} }
{
    \dim_set:Nn \l_tmpa_dim {#1}
     \begin{tikzpicture}[overlay,remember~picture]
        \node [xshift=\foremargin-\l_tmpa_dim, yshift=-\uppermargin+\l_tmpa_dim] at (current~page.north~west) (TopLeft) {};
         \node [xshift=-\spinemargin+\l_tmpa_dim, yshift=\lowermargin-\l_tmpa_dim] at (current~page.south~east) (BottomRight) {};
         \draw (TopLeft.center) rectangle (BottomRight.center);
     \end{tikzpicture}
}

\NewDocumentCommand \MakeQuaterPages {} % 4배수 페이지
{	
	\clearpage
	\pagestyle{empty}
	\mbox{}
	\int_set:Nn \l_tmpa_int { \int_mod:nn { \thepage }{ 4 } }
	\int_set:Nn \l_tmpb_int { 4 - \l_tmpa_int }
	\int_step_inline:nn { \l_tmpb_int }
	{
		\clearpage
		\mbox{}
	}
}

\NewDocumentCommand \email { m }
{
    \href{mailto:#1}{\nolinkurl{#1}}
}
\NewDocumentCommand \URL { s m }
{
    \IfBooleanTF {#1}
    { 
        \href{http://#2}{\nolinkurl{#2}}
    }{ 
        \url{#2} 
    }
}
%\urlstyle{sf}

\NewDocumentCommand \skiplines { O{1} }
{
    \vspace{#1\baselineskip}
}

\keys_define:nn { wraprule }
{
    gap      	.tl_set:N = \l_wraprule_gap,
    thickness	.tl_set:N = \l_wraprule_thickness,
    raise		.dim_set:N = \l_wraprule_raise
}

\NewDocumentCommand \WrapruleSetup { m }
{
    \keys_set:nn { wraprule } { #1 }
}

\WrapruleSetup{
    gap=\enspace,
    thickness = 0.75pt,
    raise=0.5ex
}

\NewDocumentCommand \wraprule { O{} m }
{
    \group_begin:
        \WrapruleSetup{#1}
        \hbox_set:Nn \l_tmpa_box {\l_wraprule_gap #2 \l_wraprule_gap}
        \dim_set:Nn \l_tmpa_dim { \box_wd:N \l_tmpa_box }
        \dim_set:Nn \l_tmpb_dim { \linewidth - \l_tmpa_dim }
        \noindent\raisebox{\l_wraprule_raise}{
            \rule{.5\l_tmpb_dim}{\l_wraprule_thickness}
            \raisebox{-\l_wraprule_raise}{\box_use:N \l_tmpa_box}
            \rule{.5\l_tmpb_dim}{\l_wraprule_thickness}
        }
    \group_end:
}

\NewDocumentCommand \linerule { O{} }
{
    \group_begin:
        \WrapruleSetup{#1}
        \noindent\rule[\l_wraprule_raise]{\linewidth}{\l_wraprule_thickness}
    \group_end:
}

% superscript or subscript as notes
\bool_new:N \g_annotate_bool
\tl_new:N \l_annotate_tl

\keys_define:nn { annotate }
{
    breakable   .bool_set:N = \l_annotate_breakable_bool,
    superscript .bool_set:N = \l_annotate_superscript_bool,
    opening     .tl_set:N = \l_annotate_opening,
    closing     .tl_set:N = \l_annotate_closing,
    font        .tl_set:N = \l_annotate_font,
    color       .tl_set:N = \l_annotate_color,
    space       .tl_set:N = \l_annotate_space,
    raise       .tl_set:N = \l_annotate_raise,
	indexing	.bool_set:N = \l_annotate_indexing_bool,
    star        .tl_set:N = \l_annotate_star,
}

\NewDocumentCommand \AnnotateSetup { m }
{
    \keys_set:nn { annotate } {#1}
}

\AnnotateSetup{
    breakable=true,
    superscript=true,
    font=\scriptsize,
    color=darkgray,
    space=\thinspace,
    opening={},
    closing={},
    raise=0.75ex,
	star={indexing=true},
}

\NewDocumentCommand \annotate { s t| O{} m }
{
	\group_begin:
		\AnnotateSetup{#3}
		\IfBooleanT {#1}
		{ 
			\exp_args:No \AnnotateSetup{\l_annotate_star}
		}
		\IfBooleanT {#2}
		{ 
			\AnnotateSetup{\l_bbox_breakable_adhoc_tl} 
		}
		\l_annotate_space
		\bool_if:NTF \l_annotate_breakable_bool
		{
			\exp_args:Nx \annotate_scope:n {\l_annotate_opening #4 \l_annotate_closing}
		}{
			\annotate_unbreakable:n {\l_annotate_opening #4 \l_annotate_closing}
		}
		\bool_if:NT \l_annotate_indexing_bool
		{
			\index{#4}
		}
		\l_annotate_space
	\group_end:
}

\cs_new:Npn \annotate_scope:n #1
{
    \annotate_recur:n #1 \q_nil
}

\cs_new:Nn \annotate_recur:n
{
    \quark_if_nil:NTF #1
    {
        \tl_clear:N \l_annotate_tl
    }{
        \tl_put_right:Nn \l_annotate_tl {#1}
        \annotate_breakable:V \l_annotate_tl
        \tl_clear:N \l_annotate_tl
        \peek_catcode:NTF \c_space_token
        {
            \space\annotate_recur:n
        }{
            \annotate_recur:n
        }
    }
}

\cs_new:Npn \annotate_breakable:V #1
{
    \group_begin:
        \l_annotate_font
        \color{\l_annotate_color}
		\bool_if:NTF \l_annotate_superscript_bool
		{ 
			\raisebox{\l_annotate_raise}{#1} 
		}{ 
			\raisebox{-\l_annotate_raise}{#1} 
		}		
    \group_end:
}

\cs_new:Npn \annotate_unbreakable:n #1
{
    \bool_if:NTF \l_annotate_superscript_bool
    {
        \textsuperscript{\textcolor{\l_annotate_color}{\l_annotate_font #1}}
    }{
        \textsubscript{\textcolor{\l_annotate_color}{\l_annotate_font #1}}
    }
}
\cs_set_eq:NN \anota \annotate

% Reading TSV --------------------------------
\clist_new:N \l_tsv_renderers_clist
\int_new:N \l_tsv_renderers_int
\keys_define:nn { TSV }
{
    heading             .code:n = { \cs_set_eq:NN \TSVheading #1 },
    space               .tl_set:N = \l_tsv_space_tl,
    tabs                .tl_set:N = \l_tsv_tabs_tl,
    renderers           .code:n = { \clist_set:Nn \l_tsv_renderers_clist {#1} }
}
\NewDocumentCommand \texttsv { m }{ #1 }
\NewDocumentCommand \TSVsetup { m }
{
    \keys_set:nn { TSV }{ #1 }     
}

\TSVsetup{
    heading = \section,
    space = \tab,
    tabs = { 0pt, 0.25\linewidth, 0.5\linewidth, 0.75\linewidth }
}

\ior_new:N \l_tsv_ior
\NewDocumentCommand \ReadTSV { m o }
{
    \IfValueT{#2}
    {
        \TSVsetup{ #2 }
    }
    \exp_args:No \TabPositions{ \l_tsv_tabs_tl }
    \int_set:Nn \l_tsv_renderers_int { 
        \clist_count:N \l_tsv_renderers_clist
    }   
    \ior_open:Nn \l_tsv_ior { #1 }
    \group_begin:
        \ior_str_map_inline:Nn \l_tsv_ior
        {
            \str_set:Nn \l_tmpa_str { ##1 }
            \regex_replace_all:nnN { \t }{ | } \l_tmpa_str
            \seq_set_split:NnV \l_tmpa_seq { | } \l_tmpa_str                        
            \tsv_render:N \l_tmpa_seq	            
        }
    \group_end:
    \ior_close:N \l_tsv_ior   
}

\cs_new:Npn \tsv_render:N #1
{
    \int_set:Nn \l_tmpa_int { \seq_count:N #1 }    
	\int_compare:nTF { \l_tmpa_int = 1 }
	{
        \seq_pop:NN #1 \l_tmpa_str
        \str_if_empty:NF \l_tmpa_str
        {
            \TSVheading{ \l_tmpa_str }
        }
	}{
		\int_zero:N \l_tmpb_int
		\seq_map_inline:Nn #1
		{	
            \int_incr:N \l_tmpb_int
            \tl_if_empty:nTF { ##1 } 
            {
                \null
            }{
                \tsv_render_item:Nn \l_tmpb_int { ##1 }
            }
			\int_compare:nTF { \l_tmpb_int < \l_tmpa_int }
			{
                \tl_use:N \l_tsv_space_tl                
			}{
				\par
			}
		}
	}
}

\cs_new:Npn \tsv_render_item:Nn #1 #2
{
    \tl_set_rescan:Nnn \l_tmpa_tl {}{ #2 }
    \int_compare:nTF { \l_tsv_renderers_int < #1 }
    {
        \texttsv{\l_tmpa_tl}
    }{
        % \exp_args:NNo \tl_set:Nn \l_tmpb_tl {
        %     \clist_item:Nn \l_tsv_renderers_clist { #1 } 
        % }
        % \tl_if_head_eq_charcode:fNTF { \l_tmpb_tl } \
        % {
        %     \l_tmpb_tl
        % }{
        %     \use:c { \tl_use:N \l_tmpb_tl }
        % }
        \clist_item:Nn \l_tsv_renderers_clist { #1 } 
        \l_tmpa_tl
    }
}

% templates for document elements  * * * * * * * * * * * * * * * * * * * * *

\seq_new:N \g_template_text_seq
\cs_new:Npn \template_add_text:n #1
{
    \seq_gput_right:Nn \g_template_text_seq {#1}
}

\group_begin:
    \char_set_catcode_space:n {`\ }
    \template_add_text:n {Lorem ipsum dolor sit amet, consectetuer adipiscing elit. }
    \template_add_text:n {Etiam lobortis facilisis sem. Nullam nec mi et neque pharetra sollicitudin. Praesent imperdiet mi nec ante. }
    \template_add_text:n {Donec ullamcorper, felis non sodales commodo, lectus velit ultrices augue, a dignissim nibh lectus placerat pede. Vivamus nunc nunc, molestie ut, ultricies vel, semper in, velit. Ut porttitor. Praesent in sapien. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Duis fringilla tristique neque. }
    \template_add_text:n {Sed interdum libero ut metus. Pellentesque placerat. Nam rutrum augue a leo. Morbi sed elit sit amet ante lobortis sollicitudin. Praesent blandit blandit mauris. Praesent lectus tellus, aliquet aliquam, luctus a, egestas a, turpis. Mauris lacinia lorem sit amet ipsum. Nunc quis urna dictum turpis accumsan semper.}
\group_end:

\cs_new:Npn \template_print_text:n #1
{
    \seq_item:Nn \g_template_text_seq {#1}
}

\NewDocumentCommand \tpltext { O{1} }
{
    \int_step_function:nnnN {1}{1}{#1} \template_print_text:n
}

\NewDocumentCommand \tplpara { s }
{
    \IfBooleanTF {#1}
        { \tpltext[3] }
        { \tpltext[2]  }
    \par
}

% \tpllist*[terms][enumerate]
\NewDocumentCommand \tpllist { s o o }
{
    \tplpara
    \IfValueTF {#2}
    {
        \str_set:Nn \l_tmpa_str { #2 }
    }
    {
        \IfBooleanTF{#1}
            { \str_set:Nn \l_tmpa_str { enumerate } }
            { \str_set:Nn \l_tmpa_str { itemize } }
    }
    \IfValueTF {#3}
        { \template_list:nn {\l_tmpa_str}{#3} }
        { \template_list:nn {\l_tmpa_str}{} }
}

\cs_new:Npn \template_list:nn #1 #2
{
    \begin{#1}
    \int_zero:N \l_tmpa_int
    \int_do_while:nNnn {\l_tmpa_int} < {4}
    {
        \int_incr:N \l_tmpa_int
        \str_if_eq:nnTF {terms} {#1}
            { \template_item_label: {#2} }
            { \template_item: {#2} }
    }
    \end{#1}
}

\cs_new:Npn \template_item_label: #1
{
    \tl_set:Nn \l_tmpa_tl {Term~\int_to_Alph:n {\l_tmpa_int}}
    \item[\l_tmpa_tl] \tpltext
    \tl_if_empty:nF {#1} { \template_list:nn {#1}{} }
}

\cs_new:Npn \template_item: #1
{
    \item \tpltext
    \tl_if_empty:nF {#1} { \template_list:nn {#1}{} }
}

\NewDocumentCommand \tplimage {}
{
    \par\image{uncertain}
}

\NewDocumentCommand \tpllineimg {}
{
    \lineimg{uncertain}
}

\NewDocumentCommand \tplimagetable {}
{
    \tplpara
    \par
    \begin{ImageTable}
        \tpllineimg & \tpllineimg & \tpllineimg \\
        First~item & Second~item & Third~item \\
        \tpllineimg & \tpllineimg & \tpllineimg \\
        Fourth~item & Fifth~item & Sixth~item \\
    \end{ImageTable}
}

\NewDocumentCommand \tplprocedure { O{3} }
{
    \int_set:Nn \l_tmpa_int {1}
    \int_set:Nn \l_tmpb_int {#1}
    \tplpara
    \par
    \begin{IllustEnum}*{uncertain}
        \item \tplpara
    \end{IllustEnum}
    \int_do_while:nNnn {\l_tmpa_int} < {\l_tmpb_int}
        {
            \int_incr:N \l_tmpa_int
            \par
            \begin{IllustEnum}{uncertain}
                \item \tplpara
            \end{IllustEnum}
        }
}

\NewDocumentCommand \tplactions { O{5} }
{
    \int_zero:N \l_tmpa_int 
    \int_set:Nn \l_tmpb_int {#1}
    \int_do_while:nNnn {\l_tmpa_int} < {\l_tmpb_int}
    {
        \int_incr:N \l_tmpa_int
        \str_set:Nx \l_tmpa_str { \int_to_Alph:n \l_tmpa_int }
        \section{action~\l_tmpa_str}
        \tpllist*

    }
}

\NewDocumentCommand \tplspectable {}
{
    \par
    \begin{SpecTable}
    First~spec & Value \\
    Second~spec & Value \\
    Third~spec & Value \\
    Fourth~spec & Value \\
    Fifth~spec & Value \\
    \end{SpecTable}
}

\NewDocumentCommand \tplspectables { O{3} }
{
    \int_step_inline:nnnn {1}{1}{#1}{ \tplspectable }
}

\NewDocumentCommand \tpltable {}
{
    \par
    \begin{PlaceTable}
        %\begin{tabu}{X[lp]X[lp]X[lp]}
        \begin{tabularx}{\linewidth}{XXX}
            \hline
            \textbf{A} & \textbf{B} & \textbf{C} \\\hline
            1 & 1 & 1\\
            2 & 2 & 2\\
            3 & 3 & 3\\
            4 & 4 & 4\\
            5 & 5 & 5\\
            \hline
        \end{tabularx}
    \end{PlaceTable}
}

\NewDocumentCommand \tplproblem {}
{
    \problem{Problem} \tplpara
}

\NewDocumentCommand \tplproblems { O{2} }
{
    %\listofproblems*
    \int_zero:N \l_tmpa_int 
    \int_set:Nn \l_tmpb_int {#1}
    \int_do_while:nNnn {\l_tmpa_int} < {\l_tmpb_int}
    {
        \int_incr:N \l_tmpa_int
        \str_set:Nx \l_tmpa_str { \int_to_Alph:n \l_tmpa_int }
        \problemsection{Problem~\l_tmpa_str}
        {
            \group_begin:
                \int_set:Nn \l_tmpa_int {0}
                \int_set:Nn \l_tmpb_int {#1}
                \int_do_while:nNnn {\l_tmpa_int} < {\l_tmpb_int}
                {
                    \int_incr:N \l_tmpa_int
                    \str_set:Nx \l_tmpa_str { \int_to_alph:n \l_tmpa_int }
                    \problem{Problem~\l_tmpa_str}
                    \tplpara*
                    \tpllist*
                }
            \group_end:
        }
    }
}

% chpater contents
\DeclareExpandableDocumentCommand \chaptoc {}
{
    \ifanappendix
        toc \int_to_alph:n {\c@chapter}
    \else
        toc \int_to_roman:n {\c@chapter}
    \fi
}

\NewDocumentCommand \EnableChapterContents {}
{
    \usepackage{morewrites}

    \RenewDocumentCommand \memendofchapterhook {}
    {
            \@input{\jobname.\chaptoc}%
            \if@filesw
                    \expandafter\newwrite\csname tf@\chaptoc\endcsname
                    \immediate\openout \csname tf@\chaptoc\endcsname \jobname.\chaptoc\relax
        \fi
        \bigskip
    }

    \cs_set_eq:NN \orgaddcontentsline \addcontentsline
    \RenewDocumentCommand \addcontentsline { m m m }
    {
        \orgaddcontentsline{##1}{##2}{##3}
        \str_if_eq:nnT {##1}{toc}
        {
            \str_if_eq:nnF {##2}{chapter}
            {
                \addtocontents{\chaptoc}{\protect\contentsline{##2}{##3}{\thepage}{\@currentHref}}
            }
        }
    }
}
\ExplSyntaxOff

% verbatim & literal -----------------------------------------------------------
% USE THIS METHOD:
%    \begin{reference}
%    \begin{verbatim}
%    ...    
%    \end{verbatim}
%    \end{reference}
% AN ALTERNATIVE METHOD IS
%    \begin{verbsave}
%    ...
%    \end{verbsave}
%    \verbread

\def\tmpverbfile{\jobname.vrb}
% Leave nothing after \end{} in the same line
\def\verbsave{%
    \@bsphack
    \immediate\openout \verbatim@out \tmpverbfile
    \let\do\@makeother\dospecials
    \catcode`\^^M\active
    \def\verbatim@processline{%
        \immediate\write\verbatim@out
            {\the\verbatim@line}}%
    \verbatim@start}
\def\endverbsave{%	
    \immediate\closeout\verbatim@out	
    \@esphack}

\ExplSyntaxOn

\RenewDocumentCommand \verb {v} 
{
    \texttt{#1}
}

\NewDocumentCommand \vitem { v }
{
    \item[#1]
}

\NewDocumentCommand \verbread { O{ \tmpverbfile } }
{  
	\begin{reference}
		\bool_if:NTF \g_minted_bool
		{
			\inputminted{latex}{#1}
		}{
			%\wrappingon
			\verbatimindent=0pt
			\verbatiminput{#1}
		}
    \end{reference}
}

\NewDocumentCommand \verbinput { O{ \tmpverbfile } }
{
	
	\begin{instance}
		\input{#1}
	\end{instance}
}

\NewDocumentCommand \verbrender{ s O{ \tmpverbfile } }
{
    \IfBooleanTF {#1}
    {
        \verb_render_below:n { #2 }
    }{
        \verb_render_side:n { #2 }
    }    
}

\cs_new:Npn \verb_render_below:n #1
{
    \verbread[#1]   
	\ExplSyntaxOn
    \verbinput[#1]	
	\ExplSyntaxOff 
}

\cs_new:Npn \verb_render_side:n #1
{    
    \begin{IfVartwoEnlarge}\noindent
		\begin{minipage}{.55\linewidth}
			\verbread[#1]			
        \end{minipage}
        \hfill
        \begin{minipage}{.44\linewidth}
			\ExplSyntaxOn			
            \verbinput[#1]
			\ExplSyntaxOff
        \end{minipage}
    \end{IfVartwoEnlarge}
}
\ExplSyntaxOff

% page layout thanks to https://www.kockoc.com/newgari/1119255

\newlength\memoirPleftodd \newlength\memoirPrightodd
\newlength\memoirPlefteven \newlength\memoirPrighteven
\newlength\memoirPtop \newlength\memoirPbottom
\newlength\memoirTleftodd \newlength\memoirTrightodd
\newlength\memoirTlefteven \newlength\memoirTrighteven
\newlength\memoirTtop \newlength\memoirTbottom
\newlength\memoirHleftodd \newlength\memoirHrightodd
\newlength\memoirHlefteven \newlength\memoirHrighteven
\newlength\memoirHtop \newlength\memoirHbottom
\newlength\memoirFleftodd \newlength\memoirFrightodd
\newlength\memoirFlefteven \newlength\memoirFrighteven
\newlength\memoirFtop \newlength\memoirFbottom
\newlength\memoirMleftodd \newlength\memoirMrightodd
\newlength\memoirMlefteven \newlength\memoirMrighteven
\newlength\memoirMtop \newlength\memoirMbottom

\NewDocumentCommand\calculatetrims{}
{
    \setlength\memoirPbottom{\stockheight-\paperheight-\trimtop}
    \setlength\memoirPtop{\memoirPbottom+\paperheight}
    \IfVartwo{
        \setlength\memoirPleftodd{\stockwidth-\paperwidth-\trimedge}
        \setlength\memoirPrightodd{\memoirPleftodd+\paperwidth}
        \setlength\memoirPlefteven{\memoirPleftodd}        
        \setlength\memoirPrighteven{\memoirPrightodd}
    }[
        \setlength\memoirPleftodd{\stockwidth-\paperwidth-\trimedge}
        \setlength\memoirPlefteven{\trimedge}    
        \setlength\memoirPrightodd{\memoirPleftodd+\paperwidth}
        \setlength\memoirPrighteven{\memoirPlefteven+\paperwidth}
    ]    
    \setlength\memoirTbottom{\memoirPbottom+\lowermargin}
    \setlength\memoirTtop{\memoirPtop-\uppermargin}
    \IfVartwo{
        \setlength\memoirTleftodd{\memoirPleftodd+\spinemargin}
        \setlength\memoirTrightodd{\memoirPrightodd-\foremargin}
        \setlength\memoirTlefteven{\memoirTleftodd}
        \setlength\memoirTrighteven{\memoirTrightodd}
    }[
        \setlength\memoirTleftodd{\memoirPleftodd+\spinemargin}
        \setlength\memoirTlefteven{\memoirPlefteven+\foremargin}
        \setlength\memoirTrightodd{\memoirPrightodd-\foremargin}
        \setlength\memoirTrighteven{\memoirPrighteven-\spinemargin}
    ]    
    \setlength\memoirHbottom{\memoirTtop+\headsep}
    \setlength\memoirHtop{\memoirHbottom+\headheight}
    \IfVartwo{
        \setlength\memoirHleftodd{\memoirTleftodd}
        \setlength\memoirHrightodd{\memoirTrightodd}
        \setlength\memoirHlefteven{\memoirHleftodd}        
        \setlength\memoirHrighteven{\memoirHrightodd}
    }[
        \setlength\memoirHleftodd{\memoirTleftodd}
        \setlength\memoirHlefteven{\memoirTlefteven}
        \setlength\memoirHrightodd{\memoirTrightodd}
        \setlength\memoirHrighteven{\memoirTrighteven}
    ]
    \setlength\memoirFbottom{\memoirTbottom-\footskip}
    \setlength\memoirFtop{\memoirFbottom+\headheight}
    \IfVartwo{
        \setlength\memoirFleftodd{\memoirTleftodd}
        \setlength\memoirFrightodd{\memoirTrightodd}
        \setlength\memoirFlefteven{\memoirFleftodd}       
        \setlength\memoirFrighteven{\memoirFrightodd}
    }[
        \setlength\memoirFleftodd{\memoirTleftodd}
        \setlength\memoirFlefteven{\memoirTlefteven}    
        \setlength\memoirFrightodd{\memoirTrightodd}
        \setlength\memoirFrighteven{\memoirTrighteven}
    ]
    \setlength\memoirMbottom{\memoirTbottom}
    \setlength\memoirMtop{\memoirTtop}
    \IfVartwo{
        \setlength\memoirMleftodd{\memoirTleftodd-\marginparsep-\marginparwidth}
        \setlength\memoirMrightodd{\memoirMleftodd+\marginparwidth}    
        \setlength\memoirMlefteven{\memoirMleftodd}
        \setlength\memoirMrighteven{\memoirMrightodd}
    }[
        \setlength\memoirMleftodd{\memoirTrightodd+\marginparsep}
        \setlength\memoirMlefteven{\memoirTlefteven-\marginparsep-\marginparwidth}        
        \setlength\memoirMrightodd{\memoirMleftodd+\marginparwidth}
        \setlength\memoirMrighteven{\memoirMlefteven+\marginparwidth}
    ]
}

\expandafter\def\csname pgf@sh@ns@memoir page\endcsname{rectangle}
\expandafter\def\csname pgf@sh@np@memoir page\endcsname{%
    \def\southwest{\checkoddpage\pgfqpoint{
        \ifoddpage\memoirPleftodd\else\memoirPlefteven\fi}{\memoirPbottom}}%
    \def\northeast{\checkoddpage\pgfqpoint{
        \ifoddpage\memoirPrightodd\else\memoirPrighteven\fi}{\memoirPtop}}
}
\expandafter\def\csname pgf@sh@nt@memoir page\endcsname{{1}{0}{0}{1}{0pt}{0pt}}
\expandafter\def\csname pgf@sh@pi@memoir page\endcsname{pgfpageorigin}

\expandafter\def\csname pgf@sh@ns@memoir stock\endcsname{rectangle}
\expandafter\def\csname pgf@sh@np@memoir stock\endcsname{%
  \def\southwest{\pgfqpoint{0pt}{0pt}}%
  \def\northeast{\pgfqpoint{\stockwidth}{\stockheight}}%
}
\expandafter\def\csname pgf@sh@nt@memoir stock\endcsname{{1}{0}{0}{1}{0pt}{0pt}}
\expandafter\def\csname pgf@sh@pi@memoir stock\endcsname{pgfpageorigin}

\expandafter\def\csname pgf@sh@ns@memoir text area\endcsname{rectangle}
\expandafter\def\csname pgf@sh@np@memoir text area\endcsname{%
    \def\southwest{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirTleftodd\else\memoirTlefteven\fi}{\memoirTbottom}}%
    \def\northeast{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirTrightodd\else\memoirTrighteven\fi}{\memoirTtop}}
}
\expandafter\def\csname pgf@sh@nt@memoir text area\endcsname{{1}{0}{0}{1}{0pt}{0pt}}
\expandafter\def\csname pgf@sh@pi@memoir text area\endcsname{pgfpageorigin}

\expandafter\def\csname pgf@sh@ns@memoir header area\endcsname{rectangle}
\expandafter\def\csname pgf@sh@np@memoir header area\endcsname{%
    \def\southwest{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirHleftodd\else\memoirHlefteven\fi}{\memoirHbottom}}%
    \def\northeast{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirHrightodd\else\memoirHrighteven\fi}{\memoirHtop}}
}
\expandafter\def\csname pgf@sh@nt@memoir header area\endcsname{{1}{0}{0}{1}{0pt}{0pt}}
\expandafter\def\csname pgf@sh@pi@memoir header area\endcsname{pgfpageorigin}

\expandafter\def\csname pgf@sh@ns@memoir footer area\endcsname{rectangle}
\expandafter\def\csname pgf@sh@np@memoir footer area\endcsname{%
    \def\southwest{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirFleftodd\else\memoirFlefteven\fi}{\memoirFbottom}}%
    \def\northeast{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirFrightodd\else\memoirFrighteven\fi}{\memoirFtop}}
}
\expandafter\def\csname pgf@sh@nt@memoir footer area\endcsname{{1}{0}{0}{1}{0pt}{0pt}}
\expandafter\def\csname pgf@sh@pi@memoir footer area\endcsname{pgfpageorigin}

\expandafter\def\csname pgf@sh@ns@memoir margin area\endcsname{rectangle}
\expandafter\def\csname pgf@sh@np@memoir margin area\endcsname{%
    \def\southwest{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirMleftodd\else\memoirMlefteven\fi}{\memoirMbottom}}%
    \def\northeast{\checkoddpage\pgfqpoint{
      \ifoddpage\memoirMrightodd\else\memoirMrighteven\fi}{\memoirMtop}}
}
\expandafter\def\csname pgf@sh@nt@memoir margin area\endcsname{{1}{0}{0}{1}{0pt}{0pt}}
\expandafter\def\csname pgf@sh@pi@memoir margin area\endcsname{pgfpageorigin}

\NewDocumentCommand\ShowPageLayout{}
{
    \calculatetrims
    \AddToShipoutPictureBG{
        \begin{tikzpicture}[remember picture, overlay, line width=1pt]
            \draw[red] (memoir page.south west) rectangle (memoir page.north east);
            \draw[magenta] (memoir header area.south west) rectangle (memoir header area.north east);
            \draw[blue] (memoir text area.south west) rectangle (memoir text area.north east);    
            \draw[yellow] (memoir footer area.south west) rectangle (memoir footer area.north east);
            \draw[violet] (memoir margin area.south west) rectangle (memoir margin area.north east);            
        \end{tikzpicture}
    }
}

% default setup * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% font
\ExplSyntaxOn
\bool_if:NTF \g_Noto_bool
{
    \setmainfont{Noto~Serif}[BoldFont={*~SemiBold}]
    \setsansfont{Noto~Sans}[BoldFont={*~SemiBold}]
}{
    \setmainfont{TeX~Gyre~Pagella}
    \setsansfont{TeX~Gyre~Heros}
}
\setmonofont{zco} % to type space (␣) 
\ExplSyntaxOff

% sectional divisions
\setsecnumdepth{section}
\settocdepth{subsection}
\HeadingSetup{
    chapterstyle=hzchapter,
    paragraphstyle=interval
}

% header & footer
\nouppercaseheads

% TOC
%\setlength{\cftchapternumwidth}{4.0em}
%\setlength\cftsectionnumwidth{2.5em}
%\setlength\cftsubsectionnumwidth{3.5em}

% justification & alignment
% Use \RaggedRight instead of \raggedright when using bidi
% \sloppy
\raggedbottom % \flushbottom

% colors
\definecolor{backgray}{gray}{0.9}

\LoadStyleset

% cross-reference
\renewcommand{\chapterrefname}{\chaptername~}
\renewcommand{\tablerefname}{\tablename}
\renewcommand{\figurerefname}{\figurename}

\@ifpackageloaded{minted}{
    \setminted{encoding=UTF8, fontsize=\footnotesize, tabsize=2, breaklines=true, linenos=false, frame=none}
    \patchcmd{\FV@ListVSpace}{\@topsepadd\topsep}{\vspace{.25\baselineskip}}{}{}
}{}


\endinput