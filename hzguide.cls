% fc-cache -f -v
% luaotfload-tools -update

\ProvidesClass{hzguide}[2017/07/14]

\LoadClassWithOptions{memoir}

\RequirePackage{iftex}
\RequirePackage{expl3,xparse,l3keys2e}
\RequirePackage{environ}
\RequirePackage{fontspec}
\RequirePackage{xunicode} %xltxtra
\RequirePackage{ragged2e}
\RequirePackage{csquotes}
\RequirePackage{xspace}
\RequirePackage{enumitem}
\RequirePackage{tabto}
\RequirePackage[normalem]{ulem}
\RequirePackage[svgnames,x11names,dvipsnames,hyperref,table]{xcolor}
\RequirePackage{graphicx}
\RequirePackage{eso-pic}
\RequirePackage{tikz}
\RequirePackage{tcolorbox}
\RequirePackage{tabu, longtable, multirow}
\RequirePackage{hyperref}

\hypersetup{colorlinks=true, bookmarksnumbered=true, pdfauthor={hzguide.cls}} % allcolors=darkgray
\MakeOuterQuote{"}

% TeX: ^^b7
% XeTeX: ^^^^ac00 ^^^^^^020000  \char44032 \char"AC00 \char'126000 \char`가 \char`^^^^ac00
%\let\cleardoublepage\relax to inhibit \mainmatter from producing a blank page
%\patchcommand\tableofcontents{\clearpage}{}

% class options * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

\ExplSyntaxOn

\keys_define:nn { hzguide }
{
  language    .code:n = { \LanguageSetup {#1} },
  styleset    .tl_set:N = \g_style_set,
  doctype     .code:n = { \SetDocType {#1} },
  smallerfont .bool_set:N = \g_smallerfont_bool,
  verbatim    .bool_set:N = \g_verbatim_bool,
  uprightmath .bool_set:N = \g_upright_math_bool,
  bitmap      .bool_set:N = \g_bitmap_bool
}

\tl_new:N \hzlang
\bool_new:N \g_CJK_bool
\bool_gset_false:N \g_CJK_bool

\NewDocumentCommand \LanguageSetup {m}
{
  \str_case:nn {#1}
  {
    {english}     { \tl_set:Nn \hzlang {eng} } % 0  ENGLISH
    {chinese}     { \tl_set:Nn \hzlang {chi} } % 1  中文
    {czech}       { \tl_set:Nn \hzlang {cze} } % 2  ČEŠTINA
    {danish}      { \tl_set:Nn \hzlang {dan} } % 3  DANSK
    {dutch}       { \tl_set:Nn \hzlang {dut} } % 4  NEDERLANDS
    {finnish}     { \tl_set:Nn \hzlang {fin} } % 5  SUOMI
    {french}      { \tl_set:Nn \hzlang {fre} } % 6  FRANÇAIS
    {german}      { \tl_set:Nn \hzlang {ger} } % 7  DEUTSCH
    {italian}     { \tl_set:Nn \hzlang {ita} } % 8  ITALIANO
    {japanese}    { \tl_set:Nn \hzlang {jap} } % 9  日本語
    {korean}      { \tl_set:Nn \hzlang {kor} } % 10 한국어
    {norwegian}   { \tl_set:Nn \hzlang {nor} } % 11 NORSK
    {polish}      { \tl_set:Nn \hzlang {pol} } % 12 POLSKI
    {portuguese}  { \tl_set:Nn \hzlang {por} } % 13 PORTUGUÊS
    {russian}     { \tl_set:Nn \hzlang {rus} } % 14 РУССКИЙ ЯЗЫК
    {slovakian}   { \tl_set:Nn \hzlang {slo} } % 15 SLOVENČINA
    {spanish}     { \tl_set:Nn \hzlang {spa} } % 16 ESPAÑOL
    {swedish}     { \tl_set:Nn \hzlang {swe} } % 17 SVENSKA
    {turkish}     { \tl_set:Nn \hzlang {tur} } % 18 TÜRKÇE
    {TC}          { \tl_set:Nn \hzlang {TC} } % traditional chinese
  }
}

\NewDocumentCommand \IfLang { m +m o }
{
  \str_if_eq:VnTF \hzlang {#1}
    { #2 }
    { \IfValueT {#3} {#3} }
}

% if the document type of this ...
\clist_new:N \g_doc_type
\NewDocumentCommand \SetDocType { m }
{
  \clist_gput_right:Nn \g_doc_type {#1}
}

\NewDocumentCommand \IfDocType { m +m o }
{
  \bool_set_false:N \g_tmpa_bool
  \clist_map_inline:Nn \g_doc_type
  {
    \str_if_eq:nnT {##1} {#1}
    { \bool_set_true:N \g_tmpa_bool }
  }
  \bool_if:NTF \g_tmpa_bool
  { #2 }
  { \IfValueT { #3 } { #3 } }
}

\NewDocumentCommand \IfNotDocType { m +m o }
{
  \bool_set_false:N \g_tmpa_bool
  \clist_map_inline:Nn \g_doc_type
  {
    \str_if_eq:nnT {##1} {#1}
    { \bool_set_true:N \g_tmpa_bool }
  }
  \bool_if:NTF \g_tmpa_bool
  { \IfValueT { #3 } { #3 } }
  { #2 }
}

\NewEnviron{IfDoc}[1]{\IfDocType{#1}{\BODY}[]}
\NewEnviron{IfNotDoc}[1]{\IfNotDocType{#1}{\BODY}[]}

\keys_set:nn { hzguide }
{
  verbatim = false,
  bitmap = false,
  language = english
}

\ProcessKeysOptions { hzguide }

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

\bool_if:NT \g_verbatim_bool
{
  \RequirePackage{minted}
}

\bool_if:NT \g_upright_math_bool
{
  \RequirePackage{unicode-math}
  \setmathfont[math-style=upright]{TeX~Gyre~Pagella}
}


\NewDocumentCommand \PrioritizeBitmap {}
{
  \DeclareGraphicsExtensions{.png,.jpg,.pdf}
}

\NewDocumentCommand \PrioritizeVector {}
{
  \DeclareGraphicsExtensions{.pdf,.png,.jpg}
}

\bool_if:NTF \g_bitmap_bool
  { \PrioritizeBitmap }
  { \PrioritizeVector }

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
}

\ExplSyntaxOff
% language settings -----------------------------------------------------------
\IfLang{chi}
{
  \RequirePackage{xeCJK}
  \setCJKmainfont{SourceHanSerifSC}[UprightFont={*-Regular},BoldFont={*-SemiBold}]
  \setCJKsansfont{SourceHanSansSC}[UprightFont={*-Regular},BoldFont={*-Medium}]
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
  \setCJKmainfont[BoldFont=STZhongsong]{STSong}
  \setCJKsansfont[BoldFont=STHeiti]{STXihei}
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
  \setCJKmainfont[BoldFont=HiraMinPro-W6]{HiraMinPro-W3}
  \setCJKsansfont[BoldFont=HiraKakuPro-W3]{HiraKakuPro-W3}
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
  \usepackage[hangul]{xetexko}
  %\xetexkofontregime{latin}[puncts=prevfont, colons=prevfont, cjksymbols=hangul]  
  %xetexko: \interhchar{3pt} \spaceskip=2em plus 1em minus 1em
  %\defaultfontfeatures{WordSpace={1.25, 0.5, 0.5}}
  %\XeTeXcharclass"201C = \XKlatinopening
  %\XeTeXcharclass"201D = \XKlatinclosing
  \setmainhangulfont{KoPubBatang}[Ligatures=TeX,Scale=MatchUppercase,UprightFont={*PL},BoldFont={*PM}]
  \setsanshangulfont{KoPubDotum}[Ligatures=TeX,Scale=MatchUppercase,UprightFont={*PL},BoldFont={*PB}]
  \AtBeginDocument{
    \renewcommand*{\contentsname}{차례}
    \AdmonitionSetup {
      danger=위험,
      warning=경고,
      caution=주의,
      notice=주의, %알림
      note=참고,
      symbol={\lineimg[-0.25ex]{AlertSymbol}~}
    }
    \ProblemSetup{name={}}
    %\LineImageSetup{raise=0pt}
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
  \setquotestyle{russian}
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

\ExplSyntaxOn

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
  \hbox_set:Nn \l_tmpc_box { #2 }
  \dim_set:Nn #1 { \box_wd:N \l_tmpc_box }
}

\cs_new:Npn \dim_set_toheight:Nn #1 #2
{
  \hbox_set:Nn \l_tmpc_box { #2 }
  \dim_set:Nn #1 { \box_ht:N \l_tmpc_box + \box_dp:N \l_tmpc_box }
}

% adhoc style -----------------------------------------------------------------
\keys_define:nn { adhoc }
{
  layout      .bool_set:N = \g_adhoc_layout_bool,
  heading      .bool_set:N = \g_adhoc_heading_bool,
}

\NewDocumentCommand \AdhocSetup { m }
{
  \keys_set:nn { adhoc } { #1 }
}

\AdhocSetup{layout=false, heading=false}

\NewDocumentCommand \IfNoAdhoc { m m }
{
  \str_case:nn { #1 }
  {
    {layout}  { \bool_if:NF \g_adhoc_layout_bool {#2} }
    {heading}  { \bool_if:NF \g_adhoc_heading_bool {#2} }
  }
}

% extra style set  ------------------------------------------------------------
\NewDocumentCommand \LoadStyleset {}{
\tl_if_empty:NF \g_style_set {\input{\g_style_set}}
}

\NewDocumentCommand \styleinput { m }
{
  \InputIfFileExists {../#1} {} {}
  \InputIfFileExists {#1} {} {}
}

% commonly used content -------------------------------------------------------
\keys_define:nn { commonpath }
{
  root    .tl_set:N = \g_common_path_root,
  language  .code:n = { \LanguagePathSetup{#1} }
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
  }
  {
    \tl_set:No  \g_common_path_language { \g_common_path_root #2 / }
  }
}

\CommonPathSetup{
  root = {../../../Common/},
  language = \hzlang
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

\keys_define:nn { alter }
{
  beforecolor .tl_set:N = \l_alter_beforecolor,
  aftercolor  .tl_set:N = \l_alter_aftercolor,
  font        .tl_set:N = \l_alter_font,
  hide        .bool_set:N = \l_alter_hide_bool
}

\NewDocumentCommand \AlterSetup { m }
{
  \keys_set:nn { alter } { #1 }
}

\AlterSetup{
  beforecolor=red,
  aftercolor=blue,
  font=\foreignrmfamily,
  hide=false
}

\NewDocumentCommand \alter { +m }
{
  \bool_if:NF \l_alter_hide_bool
  {
    \textcolor{\l_alter_beforecolor}{\l_alter_font #1}
  }
}

\NewEnviron{Alter}{\alter{\BODY}}

\NewDocumentCommand \HideAlter {}
{
  \bool_set_true:N \l_alter_hide_bool
}

\newlistof{listofqueries}{loq}{Queries}
\newlistentry{query}{loq}{0}
\setcounter{loqdepth}{1}

\NewDocumentCommand \query { +m o }
{
  \alter{#1}
  \IfNoValueTF {#2}
    { \addcontentsline{loq}{query}{\l_alter_font #1} }
    { \addcontentsline{loq}{query}{\l_alter_font #2} }
}

\cs_set_eq:NN \orglistofqueries \listofqueries

\RenewDocumentCommand \listofqueries { s }
{
  \group_begin:
  \bool_if:NF \l_alter_hide_bool
    {
      \color{\l_alter_beforecolor}
      \IfBooleanTF {#1} {\orglistofqueries*} {\orglistofqueries}
    }
  \group_end:
}

\NewDocumentCommand \change { s o m }
{
  \bool_if:NTF \l_alter_hide_bool
  {
    \IfBooleanTF {#1} {\ignorespaces} {#3}
  }{
    \IfBooleanTF {#1}
    {
      \textcolor{\l_alter_beforecolor}{\sout{#3}}
    }{
      \IfNoValueTF {#2}
      {
        \textcolor{\l_alter_aftercolor}{#3}
      }{
        \textcolor{\l_alter_beforecolor}{\sout{#2}}\,
        \textcolor{\l_alter_aftercolor}{#3}
      }
    }
  }
}

\cs_set_eq:NN \HideChanges \HideAlter

% letters  --------------------------------------------------------------------

\NewDocumentCommand \nil {}
{
  \rule{0pt}{0pt}
}

% \foreign[Arial]{Philanthropy}
% \foreign*{263A}
\NewDocumentCommand \SetForeignFonts { m m }
{
  \newfontfamily\foreignrmfamily{#1}[AutoFakeBold=1.5]
  \newfontfamily\foreignsffamily{#2}[AutoFakeBold=1.5]
}

\SetForeignFonts{HCR Batang}{HCR Dotum}

\tl_new:N \WithHangul
\IfLang{kor}{ \tl_set:Nn \WithHangul {\disablekoreanfonts} }

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

% symbols
\NewDocumentCommand \yea {s}
{
  \IfBooleanTF {#1}
    { \foreign*{25B3} }
    { \foreign*{2713} }
}
\NewDocumentCommand \nay {}
{
  \foreign*{2716}
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
  \keys_set:nn { segment } { #1 }
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
      \seq_set_split:Nnn \l_tempb_seq { } { ##1 }
      \seq_map_inline:Nn \l_tempb_seq
      {
        \str_case:nnF { ####1 }
        {
          {m} { \segment_include:n {M_} }
          {o} { \segment_include:n {O_} }
          {r} { \segment_include:n {R_} }
          {-} { \segment_include:n {minus} }
          {_} { \segment_include:n {space} }
          {.} { \segment_include:n {dot} }
          {?} { \segment_include:n {QuestionMark} }
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
      { \mbox{\segment_parse:n {#2}} }
      { \segment_parse:n {#2} }
  }{
    \IfBooleanTF {#1}
      { \segment_parse:n {#2} }
      { \mbox{\segment_parse:n {#2}} }
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
}
{
  \bool_if:NT \g_column_vartwo_bool
  {
    \end{adjustwidth}
  }
}

\NewDocumentEnvironment { WidenThisPage } { o o }
{
  \IfNoValueTF {#1}
  {
    \bool_if:NTF \g_column_vartwo_bool
    {
      \tl_set:Nn \l_tmpa_tl {-2.25\vartwomargin}
      \tl_set:Nn \l_tmpb_tl {-0.25\vartwomargin}
    }
    {
      \tl_set:Nn \l_tmpa_tl {-1cm}
      \tl_set:Nn \l_tmpb_tl {-1cm}
    }
  }
  {
    \tl_set:Nn \l_tmpa_tl {-1cm}
    \tl_set:Nn \l_tmpb_tl {-1cm}
  }
  \begin{adjustwidth}{\l_tmpa_tl}{\l_tmpb_tl}
}
{
  \end{adjustwidth}
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
    {letter}      { \layout_paper_letter: }
    {46}          { \layout_paper_ivvi: }
    {slide}       { \layout_paper_slide: }
    {smartphone}  { \layout_paper_smartphone: }
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
  \dim_gset:Nn \ulmargin {30mm}
  \dim_gset:Nn \lrmargin {25mm}
  \dim_gset:Nn \vartwomargin {20mm}
}

% B5
\cs_new:Nn \layout_paper_bv:
{
  \dim_gset:Nn \stockwidth {210mm}
  \dim_gset:Nn \stockheight {297mm}
  \dim_gset:Nn \paperwidth {176mm}
  \dim_gset:Nn \paperheight {250mm}
  \dim_gset:Nn \ulmargin {24mm} % 28 mm
  \dim_gset:Nn \lrmargin {22mm} % 28 mm
  \dim_gset:Nn \vartwomargin {14mm}
}

% A5
\cs_new:Nn \layout_paper_av:
{
  \dim_gset:Nn \stockwidth {176mm}
  \dim_gset:Nn \stockheight {250mm}
  \dim_gset:Nn \paperwidth {148mm}
  \dim_gset:Nn \paperheight {210mm}
  \dim_gset:Nn \ulmargin {12mm}
  \dim_gset:Nn \lrmargin {18mm}
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

% 46
\cs_new:Nn \layout_paper_ivvi:
{
  \dim_gset:Nn \stockwidth {210mm}
  \dim_gset:Nn \stockheight {297mm}
  \dim_gset:Nn \paperwidth {182mm}
  \dim_gset:Nn \paperheight {257mm}
  \dim_gset:Nn \ulmargin {28mm}
  \dim_gset:Nn \lrmargin {30mm}
  \dim_gset:Nn \vartwomargin {15mm}
}

\cs_new:Nn \layout_paper_slide:
{
  \dim_gset:Nn \stockwidth {9in}
  \dim_gset:Nn \stockheight {6in}
  \dim_gset:Nn \paperwidth {9in}
  \dim_gset:Nn \paperheight {6in}
  \tl_gset:Nn \g_layout_type {slide}
}

\cs_new:Nn \layout_paper_smartphone:
{
  \dim_gset:Nn \stockwidth {70mm}
  \dim_gset:Nn \stockheight {124mm}
  \dim_gset:Nn \paperwidth {70mm}
  \dim_gset:Nn \paperheight {124mm}
  \tl_gset:Nn \g_layout_type {smartphone}
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
        \bool_set_false:N \g_column_vartwo_bool
        \tl_gset:Nn \g_layout_type {common}
        \tl_gset:Nn \ulratio {1.2}
      }
    { vartwo } {
        \bool_set_true:N \g_column_vartwo_bool
        \tl_gset:Nn \g_layout_type {vartwo}
        \tl_gset:Nn \ulratio {1.1}
      }
  }
}

% layout configutation --------------------------------------------------------

\cs_new:Nn \layout_column_one:
{
  \setulmarginsandblock{\ulmargin}{*}{\ulratio}
  \setheadfoot{0.4\ulmargin}{0.6\ulmargin}
  \setheaderspaces{*}{*}{0.5}  % HeaderSep = 0.5 * HeaderDrop
  \setlrmarginsandblock{\lrmargin}{\lrmargin}{*}
  \g_layout_hook
  \checkandfixthelayout
}

\cs_new:Nn \layout_column_vartwo:
{
  \setulmarginsandblock{\ulmargin}{*}{\ulratio}
  \setheadfoot{0.4\ulmargin}{0.6\ulmargin}
  \setheaderspaces{*}{*}{0.5}
  \setlrmarginsandblock{3\vartwomargin}{\vartwomargin}{*}
  \setmarginnotes{.25\vartwomargin}{1.75\vartwomargin}{1ex}
  \g_layout_hook
  \checkandfixthelayout
  \let\evensidemargin\oddsidemargin
  \IfVartwo{ \dim_set:Nn \g_protrude_dim { \marginparwidth } }
}

\cs_new:Nn \layout_smartphone:
{
  \setulmarginsandblock{5mm}{10mm}{*}
  \setlrmarginsandblock{5mm}{5mm}{*}
  \setheadfoot{0mm}{5mm}
  \setlength\headsep{0mm}
  \g_layout_hook
  \checkandfixthelayout
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

% one column
\copypagestyle{common}{ruled}
\makepsmarks{common}{\foliomarks}
\makeheadrule{common}{\textwidth}{\normalrulethickness}
\makeevenhead{common}{\hffont\leftmark}{}{\hffont\evenheadinner}
\makeoddhead{common}{\hffont\oddheadinner}{}{\hffont\rightmark}
\makeevenfoot{common}{\hfhook\hffont\thepage}{}{}
\makeoddfoot{common}{}{}{\hffont\thepage\hfhook}

% vartwo column
\copypagestyle{vartwo}{companion}
\makerunningwidth{vartwo}{\headwidth}
\makeheadrule{vartwo}{\headwidth}{\normalrulethickness}
%\makefootrule{vartwo}{\headwidth}{\normalrulethickness}{1ex}
\makepsmarks{vartwo}{\foliomarks}
\makeheadposition{vartwo}{flushright}{flushright}{flushright}{flushright}
\makeevenhead{vartwo}{\hffont\leftmark}{}{\hffont\evenheadinner}
\makeoddhead{vartwo}{\hffont\oddheadinner}{}{\hffont\rightmark}
\makeevenfoot{vartwo}{\hfhook\hffont\thepage}{}{}
\makeoddfoot{vartwo}{}{}{\hffont\thepage\hfhook}

\cs_new:Nn \folio_common:
{
  \setlength{\headwidth}{\textwidth}
  \pagestyle{common}
  \copypagestyle{chapter}{common}
  \makeheadrule{chapter}{0pt}{0pt}
  \makeevenhead{chapter}{}{}{}
  \makeoddhead{chapter}{}{}{}
  \copypagestyle{nohead}{chapter}
}

\cs_new:Nn \folio_vartwo:
{
  \setlength\vartwosecindent{\marginparwidth}
  \addtolength\vartwosecindent{\marginparsep}
  \if@twocolumn
    \setlength{\headwidth}{\columnwidth}
  \else
    \setlength{\headwidth}{\textwidth}
  \fi
  \addtolength{\headwidth}{\vartwosecindent}
  \copypagestyle{chapter}{vartwo}
  \copypagestyle{nohead}{chapter}
  \makeheadrule{chapter}{0pt}{0pt}
  \makeevenhead{chapter}{}{}{}
  \makeoddhead{chapter}{}{}{}
  \pagestyle{vartwo}
}

\newcommand\foliomarks{
  \renewcommand\chaptermark[1]{\markboth{##1}{}}
  \renewcommand\sectionmark[1]{\markright{##1}}
}

%\patchcommand{\@memfront}{}{\foliomarks}
%\patchcommand{\@memmain}{}{\foliomarks}

% setup -----------------------------------------------------------------------

\tl_new:N \hffont
\tl_set:Nn \hffont {\rmfamily\small}

\keys_define:nn {hzlayout}
{
  paper           .code:n = { \layout_paper_configure:n {#1} },
  stockwidth      .dim_set:N = \stockwidth,
  stockheight     .dim_set:N = \stockheight,
  paperwidth      .dim_set:N = \paperwidth,
  paperheight     .dim_set:N = \paperheight,
  landscape       .bool_set:N = \g_layout_landscape_bool,
  column          .code:n = { \layout_column_configure:n {#1} },
  ulmargin        .dim_set:N = \ulmargin,
  ulratio         .tl_set:N = \ulratio, % specify after column
  lrmargin        .dim_set:N = \lrmargin,
  vartwomargin    .dim_set:N = \vartwomargin,
  hffont          .tl_set:N = \hffont,
  hfhook          .tl_set:N = \hfhook,
  evenheadinner   .tl_set:N = \evenheadinner,
  oddheadinner    .tl_set:N = \oddheadinner,
  evenfootinnder  .tl_set:N = \evenfootinneer,
  oddfootinner    .tl_set:N = \oddfootinner,
  showtrim        .bool_set:N = \g_layout_showtrim_bool,
  hook            .tl_set:N = \g_layout_hook
}

\bool_set_false:N \g_layout_showtrim_bool

\NewDocumentCommand \LayoutSetup { m }
{
  \keys_set:nn { hzlayout } { #1 }
  \layout_settle:
}

\cs_new:Nn \layout_settle:
{
  \bool_if:NT \g_layout_landscape_bool
    { \layout_turn_tolandscape: }

  \bool_if:NTF \g_layout_showtrim_bool
    {
      \showtrimson
      \setstocksize{\stockheight}{\stockwidth}
      \settrimmedsize{\paperheight}{\paperwidth}{*}
      \dim_set:Nn \trimtop {\stockheight-\paperheight}
      \dim_set:Nn \trimedge {\stockwidth-\paperwidth}
      \settrims{.5\trimtop}{.5\trimedge}
      \renewcommand*{\shipout}{\afterassignment\mem@shipi\setbox\@cclv=}
      \trimLmarks
    }{
      \showtrimsoff
      \setstocksize{\paperheight}{\paperwidth}
      \settrimmedsize{\paperheight}{\paperwidth}{*}
    }

  \str_case_x:nnF { \g_layout_type }
  {
    { common }    { \layout_settle_common: }
    { vartwo }    { \layout_settle_vartwo: }
    { slide }    { \layout_settle_slide: }
    { smartphone }  { \layout_settle_smartphone: }
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

\cs_new:Nn \layout_settle_smartphone:
{
  \layout_smartphone:
  \tl_set:Nn \hffont {\footnotesize}
  \makeevenfoot{plain}{}{\hffont\thepage}{}
  \makeoddfoot{plain}{}{\hffont\thepage}{}
  \pagestyle{plain}
  \copypagestyle{chapter}{plain}
  \SetObjectAlign{\centering}
  \AtBeginDocument{\sffamily}
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

\NewDocumentCommand \SectionRule {m}
{
  \SectionMultiline { #1
    \nopagebreak\vskip-1.2\onelineskip
    \IfVartwo
    {
      \rule{\headwidth}{0.75pt}
    }
    [
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
  \noindent\hspace*{-\dimexpr\vartwosecindent\relax}
  \makebox[0pt][l]{
    \parbox[t]{\dimexpr\textwidth+\vartwosecindent\relax}{\secstyle #1}
  }
}

\NewDocumentCommand \SubsectionMultiline { m }
{
  \noindent\hspace*{-\dimexpr\vartwosecindent\relax}
  \makebox[0pt][l]{
    \parbox[t]{\dimexpr\textwidth+\vartwosecindent\relax}{\subsecstyle #1}
  }
}

\NewDocumentCommand \SubsubsectionMultiline { m }
{
  \noindent\hspace*{-\dimexpr\vartwosecindent\relax}%
  \makebox[0pt][l]{%
    \parbox[t]{\dimexpr\textwidth+\vartwosecindent\relax}{\subsubsecstyle #1}%
  }
}

\NewDocumentCommand \sectionline {}
{
  \sectionalign \sectionfont \nobreak\color{\sectioncolor}
}

\NewDocumentCommand \secstyle {} { \sectionline\secfontsize }
\NewDocumentCommand \subsecstyle {} { \sectionline\subsecfontsize }
\NewDocumentCommand \subsubsecstyle {} { \sectionline\subsubsecfontsize }
\setsecheadstyle { \SectionMultiline }
\setsubsecheadstyle { \SubsectionMultiline }
%\setsubsubsecheadstyle { \SubsubsectionMultiline }
\setsubsubsecheadstyle { \subsubsecstyle }

% style configuration --------------------------------------------------------

\cs_new:Npn \style_type_configure:n #1
{
  \str_case:nn {#1}
    {
      {report}     { \style_type_report: }
      {smartphone}  { \style_type_smartphone: }
    }
}

\cs_new:Nn \style_type_report:
{
  \IfVartwo
    { \copypagestyle{report}{vartwo} }
    [ \copypagestyle{report}{plain} ]
  \makeheadrule{report}{0pt}{0pt}
  %\makeheadrule{report}{\textwidth}{\normalrulethickness}
  %\makefootrule{report}{\textwidth}{\normalrulethickness}{1ex}
  \makeoddhead{report}{}{}{}
  \makeoddfoot{report}{}{\hffont\thepage}{}
  \makeevenhead{report}{}{}{}
  \makeevenfoot{report}{}{\hffont\thepage}{}
  \pagestyle{report}
  \aliaspagestyle{chapter}{report}
  \counterwithout{section}{chapter}
  \counterwithout{figure}{chapter}
  \counterwithout{table}{chapter}
  \style_cft_configure:n {section}
}

\cs_new:Nn \style_type_smartphone:
{
  \makechapterstyle{null}{
    \renewcommand{\chapnamefont}{\chapterline\LARGE}
    \renewcommand{\chapnumfont}{\chapterline\LARGE}
    \renewcommand{\chaptitlefont}{\chapterline\LARGE}
  }
  \keys_set:nn {hzheading}
  {
    chapterstyle=firmarticle,
    cftstyle=section,
    paragraphstyle=indent
  }
  \setlist{noitemsep}
}

\cs_new:Npn \style_cft_configure:n #1
{
  \str_case:nn {#1}
  {
    {section}  { \style_cft_section:}
    {none}     { \addtodef {\tableofcontents} {\markboth{}{}} {} }
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

\cs_new:Npn \style_section_configure:n #1
{
  \clist_map_variable:nNn {#1} \l_tmpa_tl
  {
    \str_case_x:nn { \l_tmpa_tl }
    {
      {firm}    { \style_section_firm: }
      {sparse}  { \style_section_sparse: }
      {tight}   { \style_section_tight: }
      {rule}    { \setsecheadstyle { \SectionRule } }
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
  \tl_set:Nn \secfontsize { \LARGE }
  \tl_set:Nn \subsecfontsize { \Large }
  \tl_set:Nn \subsubsecfontsize { \large }
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

\cs_new:Npn \style_paragraph_configure:n #1
{
  \str_case:nn {#1}
  {
    {indent}   { \style_paragraph_indent: }
    {interval}   { \style_paragraph_interval: }
  }
}

\cs_new:Nn \style_paragraph_indent:
{
  \setlength{\parindent}{\hzparindent}
  \tl_set:Nn \l_admonition_style_basic {\setlength\parindent{\hzparindent}}
  \abnormalparskip{0pt}
  \setlist{partopsep=0pt, topsep=.25\baselineskip, itemsep=.25ex}
  \setlist[itemize]{labelindent=.5em,labelwidth=1em,labelsep=.5em,leftmargin=!}
  \setlist[enumerate]{labelindent=.5em,labelwidth=1.25em,labelsep=.5em,leftmargin=!}
  \TermsSetup{topsep=0.5\baselineskip,itemsep=.5ex}
}

\cs_new:Nn \style_paragraph_interval:
{
  \setlength{\parindent}{0em}
  \abnormalparskip{\hzparskip}
  \setlist{partopsep=0pt, topsep=.5ex, itemsep=0pt}
  \setlist[itemize]{labelindent=0em,labelwidth=1em,labelsep=.5em,leftmargin=!}
  \setlist[enumerate]{labelindent=0em,labelwidth=1.25em,labelsep=.5em,leftmargin=!}
  \TermsSetup{topsep=0.5ex,itemsep=.25ex}
}

\keys_define:nn {hzheading}
{
  linespacing           .code:n = { \setSpacing {#1} },
  type                  .code:n = { \style_type_configure:n {#1} },
  cftstyle              .code:n = { \style_cft_configure:n {#1} },
  chapterwider          .bool_set:N = \g_style_chapterwider_bool,
  chapteralign          .tl_set:N = \chapteralign,
  chapterfont           .tl_set:N = \chapterfont,
  chaptercolor          .tl_set:N = \chaptercolor,
  chapterstyle          .code:n = { \style_chapter_configure:n {#1} },
  nochaptername         .bool_set:N = \g_style_nochaptername_bool,
  sectionalign          .tl_set:N = \sectionalign,
  sectionfont           .tl_set:N = \sectionfont,
  sectioncolor          .tl_set:N = \sectioncolor,
  sectionstyle          .code:n = { \style_section_configure:n {#1} },
  sectionfontsize       .tl_set:N = \secfontsize,
  subsectionfontsize    .tl_set:N = \subsecfontsize,
  subsubsectionfontsize .tl_set:N = \subsubsecfontsize,
  paragraphstyle        .code:n = { \style_paragraph_configure:n {#1} },
  parskip               .skip_set: N = \hzparskip,
  parindent             .skip_set: N = \hzparindent,
}

\NewDocumentCommand \HeadingSetup { m }
{
  \keys_set:nn {hzheading} {#1}
  \bool_if:NT \g_style_nochaptername_bool
  {
    \def\@chapapp{}
    \IfDefined{\prenum}{ \renewcommand\prenum{} }
  }
  \bool_if:NT \g_column_vartwo_bool
  {
    \bool_if:NT \g_style_chapterwider_bool
    {
      \patchcommand{\@makechapterhead}
        {\begin{adjustwidth}{-\vartwosecindent}{0pt}}{\end{adjustwidth}}
      \patchcommand{\@makeschapterhead}
        {\begin{adjustwidth}{-\vartwosecindent}{0pt}}{\end{adjustwidth}}
    }
  }
}

\HeadingSetup{
  linespacing=1.25,
  chapterfont=\normalfont\bfseries,
  chaptercolor=black,
  sectionalign=\raggedright, %\memRTLraggedright,
  sectionfont=\normalfont\bfseries,
  sectioncolor=black,
  sectionfontsize=\Large,
  subsectionfontsize=\large,
  subsubsectionfontsize=\normalsize,
  parskip=.25\baselineskip,
  parindent=1em
}

\NewDocumentCommand \TableOfContents { s o }
{
  \group_begin:
  \IfValueT {#2} { \setSpacing{#2} }
  \IfBooleanTF {#1} { \tableofcontent* } { \tableofcontents }
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
\NewDocumentCommand \CJKchapterstyle { s }
{
  \IfBooleanTF {#1}
  {
    \bool_if:NTF \g_CJK_bool
    {
      \ifanappendix \chapnumfont\thechapter \else \chapnamefont\@chapapp \fi
    }{
      \enspace\chapnumfont\thechapter
    }
  }{
    \bool_if:NTF \g_CJK_bool
    {
      \ifanappendix \chapnamefont\@chapapp \else \chapnamefont\prenum\space\chapnumfont\thechapter \fi
    }{
      \chapnamefont\@chapapp
    }
  }
}

\makechapterstyle{null}{
  \renewcommand{\chapnamefont}{\chapterline\huge}
  \renewcommand{\chapnumfont}{\chapterline\HUGE}
  \renewcommand{\chaptitlefont}{\chapterline\Huge}
}

\makechapterstyle{hzchapter}{
  \chapterstyle{null}
  \setlength{\midchapskip}{6ex}
  %\renewcommand{\printchapternum}{\enspace\chapnumfont\thechapter}
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
  \renewcommand{\chapnamefont}{\chapterline\huge}
  \renewcommand{\chapnumfont}{\chapterline\HUGE}
  \renewcommand{\chaptitlefont}{\chapterline\Huge}
}

\makechapterstyle{hzarticlefirm}{
  \chapterstyle{null}
  \setlength{\beforechapskip}{0pt}
  \setlength{\midchapskip}{0pt}
  \setlength{\afterchapskip}{\baselineskip}
  \renewcommand{\chapterheadstart}{\vspace{\beforechapskip}}
  \renewcommand{\printchaptername}{}
  \renewcommand{\chapternamenum}{}
  \renewcommand{\printchapternum}{\chapnumfont\thechapter\quad}
  \renewcommand{\afterchapternum}{}
}

% heading utilities -----------------------------------------------

\newcounter{unsec}[chapter] % when \setsecnumdepth{chapter} is declared
\newcounter{unsubsec}[unsec]


\tl_new:N \HzJustification
\NewDocumentCommand \SetJustification { m }
{
  #1
  \tl_gset:Nn \HzJustification {#1}
  \renewcommand{\@makefntext}[1]{\makefootmark#1 ##1}
}

\AtBeginDocument{
  %\wrappingon
  \setlength{\verbatimindent}{0pt}
  \renewcommand*{\verbatimbreakchar}{}
}

\NewDocumentCommand \SectionNewpageOn { }
{
  \int_compare:nTF { \value{secnumdepth} < 1 }
  {
    \setsechook {
      \int_compare:nT { \value{unsec} > 0 } { \newpage }
      \stepcounter{unsec}
    }
  }
  {
    \setsechook {
      \int_compare:nT { \value{section} > 0 } { \newpage }
    }
  }
}

\NewDocumentCommand \SectionNewpageOff {} {  \setsechook{} }

\NewDocumentCommand \SubsectionNewpageOn { }
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

\NewDocumentCommand \SubsectionNewpageOff {} {\setsubsechook{} }

\NewDocumentEnvironment {SectionNewpage} {}
  { \SectionNewpageOn }
  { \SectionNewPageOff}


% tasks

\keys_define:nn { task }
{
  beforeskip  .skip_set:N = \l_task_before_skip,
  afterskip   .skip_set:N = \l_task_after_skip,
  font        .tl_set:N = \l_task_font,
  delimiter   .tl_set:N = \l_task_delimiter,
  inline      .bool_set:N = \l_task_inline_bool
}

\NewDocumentCommand \TaskSetup { m }
{
  \keys_set:nn {task} {#1}
}

\TaskSetup {
  beforeskip = 0.25\hzparskip,
  afterskip = -0.25\hzparskip,
  font = \bfseries,
  inline = true
}

\NewDocumentCommand \task { m }
{
  \object_skip_before:n {\l_task_before_skip}
  \group_begin:
    \l_task_font #1
  \group_end:
  \bool_if:NTF \l_task_inline_bool
    { \l_task_delimiter \space }
    { \nopagebreak\par\object_skip_after:n {\l_task_after_skip} }
}

% hyperlinks

\NewDocumentCommand \DecolorHyperlinks { O {darkgray} O {\bfseries} }
{
  \hypersetup{colorlinks=false,pdfborder={0 0 0}}
  \cs_set_eq:NN \oldtitleref \titleref
  \renewcommand\titleref[1]{\textcolor{#1}{#2\oldtitleref{##1}}}
}

% graphics * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

\graphicspath{{images/}{../images/}}

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

\keys_define:nn  { hzcaption }{

  beforeskip  .skip_set:N = \g_caption_before_skip,
  afterskip   .skip_set:N = \g_caption_after_skip,
  align       .tl_set:N = \g_caption_align,
  font        .tl_set:N = \g_caption_font,
  delimiter   .tl_set:N = \g_caption_delimiter
}

\NewDocumentCommand \CaptionSetup { m }
{
  \keys_set:nn { hzcaption } { #1 }
  \dim_set_eq:NN \abovecaptionskip \g_caption_before_skip
  \dim_set_eq:NN \belowcaptionskip \g_caption_after_skip
  \captionnamefont{ \g_caption_font }
  \captiontitlefont{ \g_caption_font }
  \captiondelim{ \g_caption_delimiter }
  \captionstyle{ \g_caption_align }
}

\CaptionSetup{
  beforeskip = 1ex,
  align = \raggedleft,
  font = \rmfamily\bfseries\small,
  delimiter=:\space,
  afterskip = 1ex
}

% objects ---------------------------------------------------------------------

\newtcbox{\objectframe}{%[1][]{
  colframe=\g_object_frame_color,
  colback=white,
  boxrule=0.5pt,
  arc=0pt,
  boxsep=3pt,
  top=0pt, bottom=0pt, left=0pt, right=0pt
}

\keys_define:nn { hzobject }
{
  beforeskip  .skip_gset:N = \g_object_before_skip,
  afterskip  .skip_gset:N = \g_object_after_skip,
  framecolor  .tl_set:N = \g_object_frame_color
}

\NewDocumentCommand \ObjectSetup { m }
{
  \keys_set:nn { hzobject } { #1 }
}

\cs_new:Npn \object_skip_before:n #1
{
  \dim_compare:nTF { #1 != 0pt }
    { \skip_set:Nn \l_tmpa_skip {#1} }
    { \skip_set:Nn \l_tmpa_skip {\g_object_before_skip} }
  \vspace{\l_tmpa_skip}\noindent
}

\cs_new:Npn \object_skip_after:n #1
{
  \dim_compare:nTF { #1 != 0pt }
    { \skip_set:Nn \l_tmpa_skip {#1} }
    { \skip_set:Nn \l_tmpa_skip {\g_object_after_skip} }
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
}

\ObjectSetup{
  beforeskip=.5\baselineskip,
  afterskip=.5\baselineskip,
  framecolor=gray
}

% common variables ------------------------------------------------------------

\dim_zero_new:N \g_protrude_dim
\box_new:N \l_image_box
\box_new:N \l_text_box

% \placeimage[...]{image} -----------------------------------------------------

\keys_define:nn { placeimage }
{
  beforeskip    .skip_set:N = \l_placeimage_before_skip,
  afterskip     .skip_set:N = \l_placeimage_after_skip,
  extraskip     .skip_set:N = \l_placeimage_extra_skip,
  float         .bool_set:N = \l_placeimage_float_bool,
  frame         .bool_set:N = \l_placeimage_frame_bool,
  scale         .tl_set:N = \l_placeimage_scale,
  flush         .bool_set:N = \l_placeimage_flush_bool,
  landscape     .bool_set:N = \l_placeimage_landscape_bool,
  align         .tl_set:N = \l_placeimage_align,
  caption       .tl_set:N = \l_placeimage_caption,
  label         .tl_set:N = \l_placeimage_label,
  legend        .bool_set:N = \l_placeimage_legend_bool,
  showfilename  .bool_set:N = \l_placeimage_showfilename_bool,
  star          .tl_set:N = \l_placeimage_star,
  vbar          .tl_set:N = \l_placeimage_vbar
}
\bool_new:N \l_placeimage_extra_bool

\NewDocumentCommand \PlaceImageSetup { m }
{
  \keys_set:nn { placeimage } {#1}
}

\PlaceImageSetup{
  beforeskip=0pt,
  afterskip=0pt,
  extraskip=1em,
  float=false,
  frame=false,
  scale=1,
  landscape=false,
  legend=false,
  showfilename=false,
  star=frame,
  vbar=landscape
}

\NewDocumentCommand \placeimage { s t| O{} m o d() }
{
  \group_begin:
  \IfValueTF{#5} {
    \bool_set_true:N \l_placeimage_extra_bool
  }{
    \bool_set_false:N \l_placeimage_extra_bool
  }
  \IfBooleanT {#1}
    { \exp_args:No \PlaceImageSetup{\l_placeimage_star} }
  \IfBooleanT {#2}
    { \exp_args:No \PlaceImageSetup{\l_placeimage_vbar} }
  \PlaceImageSetup{#3}
  \IfValueT{#6} { \tl_set:Nn \l_placeimage_caption {#6} }
  \tl_if_empty:NT \l_placeimage_label
    {
      \IfValueTF{#5} {
        \tl_set:Nn \l_placeimage_label {#4~#5}
      }{
        \tl_set:Nn \l_placeimage_label {#4}
      }
    }
  \placeimage_save:nn {#4} {#5}
  \bool_if:NTF \l_placeimage_float_bool {
    \begin{figure}
    \placeimage_put:
    \end{figure}
  }{
    \object_skip_before:n {\l_placeimage_before_skip}
    \placeimage_put:
    \object_skip_after:n {\l_placeimage_after_skip}
  }
  \group_end:
}

\cs_new:Npn \placeimage_save:nn #1 #2
{
  \bool_if:NTF \l_placeimage_frame_bool
  {
    \bool_if:NTF \l_placeimage_extra_bool {
      \hbox_set:Nn \l_image_box{
        \objectframe{
          \includegraphics[scale=\l_placeimage_scale]{#1}
          \hspace{\l_placeimage_extra_skip}
          \includegraphics[scale=\l_placeimage_scale]{#2}
        }
      }
    }{
      \hbox_set:Nn \l_image_box{
        \objectframe{
          \includegraphics[scale=\l_placeimage_scale]{#1}
        }
      }
    }
   }
   {
     \bool_if:NTF \l_placeimage_extra_bool {
      \hbox_set:Nn \l_image_box{
          \includegraphics[scale=\l_placeimage_scale]{#1}
          \hspace{\l_placeimage_extra_skip}
          \includegraphics[scale=\l_placeimage_scale]{#2}
      }
    }{
      \hbox_set:Nn \l_image_box{
          \includegraphics[scale=\l_placeimage_scale]{#1}
      }
    }
   }
}

\cs_new:Nn \placeimage_put:
{
  \bool_if:NTF \l_placeimage_landscape_bool
    { \placeimage_put_landscape: }
    { \placeimage_put_portrait: }
}

\cs_new:Nn \placeimage_put_portrait:
{
  \bool_if:NTF \l_placeimage_flush_bool
  {
    \hspace*{-\vartwosecindent}
  }
  {
    \dim_compare:nTF { \g_protrude_dim > 0pt }
    {
      \dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_image_box }
      \object_locate:N \l_tmpa_dim
    }{
      \dim_set:Nn \l_tmpa_dim { \linewidth }
    }
  }
  \begin{minipage}{\l_tmpa_dim}
    \l_placeimage_align\nil
    \box_use:N \l_image_box
    \placeimage_caption:
  \end{minipage}
}

\cs_new:Nn \placeimage_put_landscape:
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
      \l_placeimage_align\nil
      \box_use:N \l_image_box
      \placeimage_caption:
    \end{minipage}
  }
}

\cs_new:Nn \placeimage_caption:
{
  \bool_if:NT \l_placeimage_showfilename_bool
  {
    \tl_set:Nx \l_tmpa_tl {\l_placeimage_label}
    \legend{\tl_to_str:N \l_tmpa_tl}
  }
  \tl_if_empty:NF \l_placeimage_caption
  {
    \bool_if:NTF \l_placeimage_legend_bool
    {
      \legend{\l_placeimage_caption}
    }
    {
      \imgcaption{\l_placeimage_caption}
      \label{\l_placeimage_label}
    }
  }
}

% \illustimage*^[option]{image}(caption){ text } -------------------------------
%\illustimage[options]{filename}(caption){description}
%\illustimage*: user-specified action
%\illustimage^: use firstskip

\bool_new:N \in_illustimage
\keys_define:nn { illustimage }
{
  first           .bool_set:N = \l_illustimage_first_bool,
  firstskip       .skip_set:N = \l_illustimage_first_skip,
  beforeskip      .skip_set:N = \l_illustimage_before_skip,
  afterskip       .skip_set:N = \l_illustimage_after_skip,
  frame           .bool_set:N = \l_illustimage_frame_bool,
  gap             .dim_set:N = \l_illustimage_gap,
  scale           .tl_set:N = \l_illustimage_scale,
  position        .tl_set:N = \l_illustimage_position,
  verticaloffset  .tl_set:N = \l_illustimage_voffset,
  verticalalign   .tl_set:N = \l_illustimage_valign,
  caption         .tl_set:N = \l_illustimage_caption,
  label           .tl_set:N = \l_illustimage_label,
  legend          .bool_set:N = \l_illustimage_legend_bool,
  width           .dim_set:N = \l_illustimage_width_dim, 
  broad           .bool_set:N = \l_illustimage_broad_bool, % take the full width in case of vartwo
  flush           .bool_set:N = \l_illustimage_flush_bool,
  showfilename    .bool_set:N = \l_illustimage_showfilename_bool,
  textstyle       .tl_set:N = \l_illustimage_textstyle,
  star            .tl_set:N = \l_illustimage_star
}

\NewDocumentCommand \IllustImageSetup { m }
{
  \keys_set:nn { illustimage } { #1 }
}

\IllustImageSetup{
  first=false,  
  beforeskip=.15\baselineskip,
  afterskip=.15\baselineskip,
  firstskip=0pt,
  frame=false,
  width=0pt,
  position=left,
  verticaloffset=0pt,
  verticalalign=t,
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
  \bool_set_true:N \in_illustimage
  %\illustimage_clear:
  \IfBooleanT {#1}
    { \exp_args:No \IllustImageSetup{\l_illustimage_star} }
  \IfBooleanT {#2}
    { \IllustImageSetup{first=true} }
  \IllustImageSetup{#3}
  \bool_if:NT \l_illustimage_broad_bool
  {
    \bool_if:NT \g_column_vartwo_bool
      { \begin{adjustwidth}{-\vartwosecindent}{0pt} }
  }
  \IfValueT{#5} { \tl_set:Nn \l_illustimage_caption {#5} }
  % save image
  \tl_if_empty:NT \l_illustimage_label
  {
    \tl_set:Nn \l_illustimage_label {#4}
  }
  \bool_if:NTF \l_illustimage_frame_bool
  {
    \hbox_set:Nn \l_image_box
      { \objectframe{\includegraphics[scale=\l_illustimage_scale]{#4}} }
   }
   {
     \hbox_set:Nn \l_image_box
       { \includegraphics[scale=\l_illustimage_scale]{#4} }
   }
  % save text
  \dim_compare:nTF { \l_illustimage_width_dim > 0pt }
  {
    \dim_set_eq:NN \l_tmpa_dim \l_illustimage_width_dim
    \dim_set_towidth:Nn \l_tmpb_dim { \box_use:N \l_image_box }
    \dim_compare:nT { \l_tmpa_dim < \l_tmpb_dim }
      { \dim_set_eq:NN \l_tmpa_dim \l_tmpb_dim }
  }
  {
    \dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_image_box }
  }
  \dim_set:Nn \l_tmpb_dim { \linewidth - \l_tmpa_dim - \l_illustimage_gap }
  \hbox_set:Nn \l_text_box
  {
    \begin{minipage}{\l_tmpb_dim}
      \HzJustification\l_illustimage_textstyle #6
    \end{minipage}
  }
  \illustimage_put:
  \bool_if:NT \l_illustimage_broad_bool
  {
    \bool_if:NT \g_column_vartwo_bool
      { \end{adjustwidth} }
  }
  \bool_set_false:N \in_illustimage
  \group_end:
}

\cs_new:Nn \illustimage_put:
{
  \str_case_x:nn { \l_illustimage_position }
  {
    {left}   { \illustimage_put_left: }
    {right}  { \illustimage_put_right: }
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
  \begin{minipage}[\l_illustimage_valign]{\linewidth} 
    \begin{minipage}[\l_illustimage_valign]{\l_tmpa_dim}
      \vspace{0pt}
      \bool_if:NT \l_illustimage_broad_bool
      {
        \bool_if:NT \l_illustimage_flush_bool {\hfill}
      }
      \box_use:N \l_image_box      
      \illustimage_caption:      
    \end{minipage}
    \hfill 
    \begin{minipage}[\l_illustimage_valign]{\l_tmpb_dim}
      \vspace{0pt}
      \begin{minipage}{\linewidth}        
        \vspace{\l_illustimage_voffset}
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
  \begin{minipage}[\l_illustimage_valign]{\linewidth}
    \begin{minipage}[\l_illustimage_valign]{\l_tmpb_dim}
      \vspace{0pt}
      \begin{minipage}{\linewidth}        
        \vspace{\l_illustimage_voffset}
        \box_use:N \l_text_box        
      \end{minipage}
      \vspace{0pt}
    \end{minipage}
    \hfill
    \begin{minipage}[\l_illustimage_valign]{\l_tmpa_dim}
      \vspace{0pt}
      \bool_if:NT \l_illustimage_broad_bool
      {
        \bool_if:NT \l_illustimage_flush_bool {\hfill}
      }
      \box_use:N \l_image_box
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
    \bool_if:NTF \l_illustimage_legend_bool
    {
      \legend{\l_illustimage_caption}
    }
    {
      \imgcaption{\l_illustimage_caption}
      \label{\l_illustimage_label}
    }
  }
}


\NewEnviron{IlluImg}[1]{\illustimage{#1}{\BODY}}
\NewDocumentEnvironment {IllustImage} { s o m d() }
{
  \IfBooleanT {#1}
    { \exp_args:No \IllustImageSetup{\l_illustimage_star} }
  \IfValueT {#2} { \IllustImageSetup{#2} }
  \IfValueT {#4} { \tl_set:Nn \l_illustimage_caption {#4} }
  \IlluImg{#3}
}
{
  \endIlluImg
}

\NewDocumentCommand \illustsymbol { O{} m +m }
{
  \illustimage[frame=false, verticaloffset=0.75ex, verticalalign=m, #1]{#2}{#3}
}

\NewDocumentCommand \illuitem { O{} m m }
{
  \illustimage[#1] { #2 }
  {
    \begin{itemize}
      #3
    \end{itemize}
  }
}

\NewEnviron{IlluItem}[2][]{ \illuitem[#1]{#2}{\BODY} }

\NewDocumentCommand \illuenum { s t| }
{
  \IfBooleanTF {#1}
  {
    \IfBooleanTF {#2}
    { \IllustEnumerateStartAdhoc }
    { \IllustEnumerateStart }
  }{
    \IfBooleanTF {#2}
    { \IllustEnumerateContinueAdhoc }
    { \IllustEnumerateContinue }
  }
}

\NewEnviron{IlluEnum*}[2][]{ \illuenum*[#1]{#2}{\BODY} }
\NewEnviron{IlluEnum}[2][]{ \illuenum[#1]{#2}{\BODY} }
\NewEnviron{IlluEnum*|}[2][]{ \illuenum*|[#1]{#2}{\BODY} }
\NewEnviron{IlluEnum|}[2][]{ \illuenum|[#1]{#2}{\BODY} }
\NewEnviron{IlluEnum*+}[2][]{ \illuenum*|[#1]{#2}{\BODY} }
\NewEnviron{IlluEnum+}[2][]{ \illuenum|[#1]{#2}{\BODY} }

\NewDocumentCommand \IllustEnumerateStart { O{} m +m }
{
  \illustimage[first=true,#1]{#2}
  {
    \begin{enumerate}[series=IlluEnum]
      #3
    \end{enumerate}
  }
}

\NewDocumentCommand \IllustEnumerateContinue { O{} m +m }
{
  \illustimage[#1]{#2}
  {
    \begin{enumerate}[series=IlluEnum, resume=IlluEnum]
      #3
    \end{enumerate}
  }
}

\NewDocumentCommand \IllustEnumerateStartAdhoc { O{} m +m }
{
  \illustimage*[first=true, #1]{#2}
  {
    \begin{enumerate}[series=IlluEnum]
      #3
    \end{enumerate}
  }
}

\NewDocumentCommand \IllustEnumerateContinueAdhoc { O{} m +m }
{
  \illustimage*[#1]{#2}
  {
    \begin{enumerate}[series=IlluEnum, resume=IlluEnum]
      #3
    \end{enumerate}
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

\NewDocumentCommand \lineimg { O { \l_lineimg_raise } m }
{
  \raisebox{#1}{
    \,\includegraphics[scale=\l_lineimg_scale]{#2}\,
  }
  \bool_if:NT { \l_lineimg_showfilename_bool}
  {
    \group_begin:
      \tiny \tl_to_str:n { #2 }
    \group_end:
  }
}

\NewDocumentCommand \listimage { m }
{
  \par\lineimg[0pt]{#1}
}

% \placetable[]{ } ------------------------------------
\taburowcolors{white .. backgray}
\newcommand\tableheadfont{\bfseries}
\NewExpandableDocumentCommand\TableHeadFont{}{\rowfont{\tableheadfont}}

\cs_new:Npn \placetable_footnotestyle:n #1
{
  \renewcommand\thefootnote{ \use:c {#1} {footnote} }
  \renewcommand\thempfootnote{ \use:c {#1} {mpfootnote} }
}

\keys_define:nn { placetable }
{
  beforeskip    .skip_set:N = \l_placetable_before_skip,
  afterskip     .skip_set:N = \l_placetable_after_skip,
  float         .bool_set:N = \l_placetable_float_bool,
  align         .tl_set:N = \l_placetable_align,
  landscape     .bool_set:N = \l_placetable_landscape_bool,
  caption       .tl_set:N = \l_placetable_caption,
  label         .tl_set:N = \l_placetable_label,
  legend        .bool_set:N = \l_placetable_legend_bool,
  font          .tl_set:N = \l_placetable_font,
  fontsize      .tl_set:N = \l_placetable_fontsize,
  hook          .tl_set:N = \l_placetable_hook,
  footnote      .tl_set:N = \l_placetable_footnote,
  footnotestyle .code:n = { \placetable_footnotestyle:n {#1} },
  stretch       .tl_set:N = \l_placetable_stretch,
  norowcolor    .bool_set:N  = \l_placetable_norowcolor_bool
}

\NewDocumentCommand \TableSetup { m }
{
  \keys_set:nn { placetable } { #1 }
}

\cs_set_eq:NN \PlaceTableSetup \TableSetup

\TableSetup{
  beforeskip=0pt,
  afterskip=0pt,
  float=false,
  landscape=false,
  legend=false,
  font=\rmfamily,
  fontsize=\small,
  footnotestyle=arabic,
  stretch=1
}

%\cs_new:Nn \placetable_clear:
%{
%  \tl_clear:N \l_placetable_caption
%  \tl_clear:N \l_placetable_label
%  \tl_clear:N \l_placetable_footnote
%}

\NewDocumentCommand \placetable { O{} d() d<> m }
{
  \group_begin:
  %\placetable_clear:
  \PlaceTableSetup{#1}
  \IfValueT{#2} { \tl_set:Nn \l_placetable_caption {#2} }
  \IfValueT{#3} { \tl_set:Nn \l_placetable_footnote {#3} }
  \bool_if:NT \l_placetable_norowcolor_bool { \taburowcolors{} }
  \hbox_set:Nn \l_text_box
  {
    \tl_set:Nn \arraystretch {\l_placetable_stretch}
    \l_placetable_font
    \l_placetable_fontsize
    \l_placetable_hook
    #4
  }
  \bool_if:NTF \l_place_float_bool
  {
    \begin{table}
    \placetable_put:N \l_text_box
    \end{table}
  }
  {
    \object_skip_before:n {\l_placetable_before_skip}
    \placetable_put:
    \object_skip_after:n {\l_placetable_after_skip}
  }
  \group_end:
}

\cs_new:Nn \placetable_put:
{
  \bool_if:NTF \l_placetable_landscape_bool
    { \placetable_put_landscape: }
    { \placetable_put_portrait: }
}

\cs_new:Nn \placetable_put_portrait:
{
  \dim_compare:nTF { \g_protrude_dim > 0pt }
  {
    \dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_text_box }
    \object_locate:N \l_tmpa_dim
  }{
    \dim_set:Nn \l_tmpa_dim { \linewidth }
  }
  \begin{minipage}{\l_tmpa_dim}
    \placetable_caption:
    \box_use:N \l_text_box
    \placetable_footnote:
  \end{minipage}
}

\cs_new:Nn \placetable_put_landscape:
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
      \l_placetable_align\nil
      \placetable_caption:
      \box_use:N \l_text_box
      \placetable_footnote:
    \end{minipage}
  }
}

\cs_new:Nn \placetable_caption:
{
  \tl_if_empty:NF \l_placetable_caption
  {
    \bool_if:NTF \l_placetable_legend_bool
    {
      \legend{\l_placetable_caption}
    }
    {
      \tabcaption{\l_placetable_caption}
      \label{\l_placetable_label}
    }
  }
}

\cs_new:Nn \placetable_footnote:
{
  \tl_if_empty:NF \l_placetable_footnote
  {
    \vspace{-.5\baselineskip}\par
    \begin{minipage}{\linewidth}
      \setfootnoterule{0pt}{0pt}{0pt}
      \l_placetable_footnote
    \end{minipage}
  }
}

\NewEnviron{PlaceTable}{\placetable{\BODY}}

\NewDocumentEnvironment { Table } { o d() d<> }
{
  \IfValueT{#1} { \PlaceTableSetup{#1} }
  \IfValueT{#2} { \tl_set:Nn \l_placetable_caption {#2} }
  \IfValueT{#3} { \tl_set:Nn \l_placetable_footnote {#3} }
  \PlaceTable
}
{
  \endPlaceTable
}

\NewEnviron{spectable}{
  \placetable{
    \begin{tabu}{X[lm]X[lm]}
    \hline\BODY\hline
    \end{tabu}
  }
}

\NewEnviron{spectablex}{
  \placetable{
    \begin{tabu}{lX[lm]}
    \hline\BODY\hline
    \end{tabu}
  }
}

\NewDocumentEnvironment { SpecTable } { s o d() d<> }
{
  \IfValueT{#2} { \PlaceTableSetup{#2} }
  \IfValueT{#3} { \tl_set:Nn \l_placetable_caption {#3} }
  \IfValueT{#4} { \tl_set:Nn \l_placetable_footnote {#4} }
  \IfBooleanTF{#1}{\spectablex}{\spectable}
}
{
  \IfBooleanTF{#1}{\endspectablex}{\endspectable}
}

\NewEnviron{imagetable}{
  \placetable[stretch=1.3]{
    \taburowcolors{}
    \begin{tabu}{X[c]X[c]X[c]}
    \BODY
    \end{tabu}
  }
}

\NewDocumentEnvironment { ImageTable } { d<> }
{
  \IfValueT{#1} { \tl_set:Nn \l_placetable_footnote {#1} }
  \imagetable
}
{
  \endimagetable
}

\NewDocumentCommand \TableCommon { O{} }
{
  \PlaceTableSetup{#1}
  \tl_set:Nn \arraystretch {\l_placetable_stretch}
  \l_placetable_font
  \l_placetable_fontsize
  \taburowcolors{backgray .. white}
}

\DeclareExpandableDocumentCommand \LongTableHeadFont {}
{
  \rowcolor{white}\rowfont{\bfseries}
}

%\NewDocumentEnvironment {LongTable} { O{} }
%{
%  \group_begin:
%  \TableCommon
%}
%{
%  \group_end:
%}

%\begin{longtabu}to \linewidth{X[c]X[2]X[2]X[2]}
%\hline \LongTableHeadFont $x$ (°) & $\sin x$ & $\cos x$ & $\tan x$ \\ \hline \endfirsthead
%\hline \LongTableHeadFont $x$ (°) & $\sin x$ & $\cos x$ & $\tan x$ \\ \hline \endhead
%\hline \endfoot
%\hline \endlastfoot
%0 & 0 & 1 & 0 \\
%1 & 0.0174524 & 0.99984769 & 0.01745506 \\
%2 & 0.03489949 & 0.99939082 & 0.03492076 \\
%89 & 0.99984769 & 0.0174524 & 57.28996148 \\
%90 & 1 & 0 & $\infty$ % Leave out "\\" from the last row.
%\end{longtabu}

% object utilities ------------------------------------------------------------

\NewDocumentCommand \SetObjectAlign { m }
{
  \CaptionSetup { align = #1 }
  \PlaceImageSetup { align = #1 }
  \PlaceTableSetup { align = #1 }
}

\NewDocumentCommand \ShowImageFilename { s }
{
  \PlaceImageSetup{showfilename=true}
  \IllustImageSetup{showfilename=true}
  \MarginImageSetup{showfilename=true}
  \LineImageSetup{showfilename=true}
  \IfBooleanT{#1} { \LineImageSetup{showfilename=true} }
}

\NewDocumentCommand \HideImageFilename { }
{
  \PlaceImageSetup{showfilename=false}
  \IllustImageSetup{showfilename=false}
  \MarginImageSetup{showfilename=false}
  \LineImageSetup{showfilename=false}
}

\NewDocumentCommand \imagescale { m o }
{
  \IfNoValueTF {#2}
  {
    \tl_set:Nn \l_placeimage_scale {#1}
    \tl_set:Nn \l_illustimage_scale {#1}
    \tl_set:Nn \l_lineimg_scale {#1}
  }
  {
    \str_case:nn {#2}
    {
      {\placeimage}   { \tl_set:Nn \l_placeimage_scale {#1} }
      {\illustimage}  { \tl_set:Nn \l_illustimage_scale {#1} }
      {\lineimg}      { \tl_set:Nn \l_lineimg_scale {#1} }
    }
  }
}

\NewDocumentEnvironment {ImageScale} { m m }
{
  \group_begin:
  \imagescale{#1}{#2}
}
{
  \group_end:
}

\ior_new:N \l_txt_io

\NewDocumentCommand \MakeAlbum { s O {0.5} m }
{
  \PlaceImageSetup{scale=#2}
  \IfBooleanTF {#1}
    { \PlaceImageSetup{showfilename=false} }
    { \PlaceImageSetup{showfilename=true} }
  \ior_open:Nn \l_txt_io { #3 }
  \ior_map_inline:Nn \l_txt_io
  {
    \tl_set:Nn \l_tmpa_tl { ##1 }
    \tl_trim_spaces:N \l_tmpa_tl
    \tl_if_empty:NF { \l_tmpa_tl }
    {
      \placeimage{\l_tmpa_tl}\par
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
% Use \IndexingOff disable the indexing function of term-related macros including \term.

\bool_new:N \g_indexing_bool
\NewDocumentCommand \IndexingEnable {}
{
  \makeindex
  \bool_gset_true:N \g_indexing_bool
  \bool_gset_true:N \l_terms_indexing_bool
}
\NewDocumentCommand \IndexingDisable {}
{
  \bool_gset_false:N \g_indexing_bool
  \bool_gset_false:N \l_terms_indexing_bool
}
\IndexingDisable

\NewDocumentCommand \hz_indexing {o m}
{
  \bool_if:NT \g_indexing_bool
  {
    \IfNoValueTF {#1} { \index{#2} } { \index{#1@#2} }
  }
}

% \term[sort]{\LaTeX}: use the starred version to emphasize the argument.
\keys_define:nn {term}
{
  color    .tl_set:N = \l_term_color,
  emphfont  .tl_set:N = \l_term_emphfont
}
\NewDocumentCommand \TermSetup { m }
{
  \keys_set:nn {term} {#1}
}

\TermSetup{
  color=black,
  emphfont=\itshape
}

\NewDocumentCommand \term { s o m }
{
  \hz_indexing [#2] {#3}
  \IfBooleanTF {#1}
    { \textcolor{\l_term_color}{\l_term_emphfont #3} }
    { \textcolor{\l_term_color}{#3} }
}

% \ui[sort]{Open}: use the starred version not to index the arguments.
\keys_define:nn {ui}
{
  color   .tl_set:N = \l_ui_color,
  font    .tl_set:N = \l_ui_font,
  default .tl_set:N = \l_UI_default,
  star    .tl_set:N = \l_UI_star,
  vbar    .tl_set:N = \l_UI_vbar
}
\NewDocumentCommand \UISetup { m }
{
  \keys_set:nn {ui} {#1}
}

\UISetup{
  color=black,
  font=\sffamily\mdseries,
  default={color=\l_ui_color, font=\l_ui_font}
}

\NewDocumentCommand \ui {s o m}
{
  \IfBooleanF {#1} { \hz_indexing [#2] {#3} }
  \textcolor{\l_ui_color}{\l_ui_font #3}
}
% \mi[sort][OK]: use the starred version to index the arguments.
\NewDocumentCommand \mi {s o m }
{
  \IfBooleanTF {#1} { \ui[#2]{#3} } { \ui*[#2]{#3} }
}

\NewDocumentCommand \menu {s o o m m }
{
  \IfBooleanTF {#1}
  {
    \IfValueT {#2} { \ui{#2} ~ > ~ }
    \IfValueT {#3} { \ui{#3} ~ > ~ }
    \ui{#4} ~ > ~ \ui{#5}
  }{
    \IfValueT {#2} { \ui*{#2} ~ > ~ }
    \IfValueT {#3} { \ui*{#3} ~ > ~ }
    \ui*{#4} ~ > ~ \ui{#5}
  }
}

\newcommand\ucfont{\ttfamily\bfseries}

\NewDocumentCommand \uc { s t{|} v }
{
  \IfBooleanTF{#1}
  {
    ``{\ucfont #3}''
  }
  {  \IfBooleanTF{#2}
    { `{\ucfont #3}' }
    { {\ucfont #3} }
  }
}

\NewDocumentCommand \vitem { v }
{
  \item[#1]
}

\NewDocumentEnvironment { UC } {}
{
  \begin{terms}[font=\ttfamily]
}
{
  \end{terms}
}

% lists  -------------------------------------------------------

\NewDocumentEnvironment {enumerate*} {}
{ \begin{enumerate}[label=\arabic*)] }
{ \end{enumerate} }

\NewDocumentEnvironment {itemize*} {}
{ \begin{itemize}\tightlist }
{ \end{itemize} }

% terms list
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
           { \tl_set:Nn \l_terms_marker_i {##1\hskip\l_terms_markersep} }
       }
       {1} {
         \tl_if_empty:nTF {##1}
           { \tl_set:Nn \l_terms_marker_ii {} }
           { \tl_set:Nn \l_terms_marker_ii {##1\hskip\l_terms_markersep} }
       }
     }
    \int_incr:N \l_tmpa_int
  }
}

\tl_set:Nn \l_terms_marker {
  \int_compare:nT { \@listdepth = 1 }  {\l_terms_marker_i}
  \int_compare:nT { \@listdepth = 2 }  {\l_terms_marker_ii}
}

\keys_define:nn { terms }
{
  offset      .skip_set:N = \l_terms_offset,
  marker      .code:n = { \terms_define_marker:n {#1} },
  markersep   .skip_set:N = \l_terms_markersep,
  enumerate   .bool_set:N = \l_terms_enumerate_bool,
  base        .tl_set:N = \l_terms_base,
  font        .tl_set:N = \l_terms_font,
  color       .tl_set:N = \l_terms_color,
  delimiter   .tl_set:N = \l_terms_delimiter,
  labelwidth  .dim_set:N = \l_terms_labelwidth,
  labelsep    .skip_set:N = \l_terms_labelsep,
  index       .bool_set:N = \l_terms_indexing_bool,
  multiline   .bool_set:N = \l_terms_multiline_bool,
  newline     .bool_set:N = \l_terms_newline_bool,
  topsep      .skip_set:N = \l_terms_topsep,
  itemsep     .skip_set:N  = \l_terms_itemsep,
  star        .tl_set:N = \l_terms_star,
  vbar        .tl_set:N = \l_terms_vbar
}
\NewDocumentCommand \TermsSetup {m}
{
  \keys_set:nn {terms} {#1}
}

\TermsSetup{
  offset=0em,
  marker={{},\textbullet},
  markersep=0.25em,
  base=MM,
  font=\bfseries,
  color=black,
  delimiter=\hfill,
  labelsep=0.5em,
  index=true,
  newline=false,
  star={itemsep=-1ex}
}

\cs_new:Npn \terms_leftmargin:n #1
{
  \dim_set:Nn \leftmargin { \labelwidth+\labelsep }
  \int_compare:nT { \@listdepth = 1 }
  {
    \tl_if_blank:nF { #1 } { \addtolength\leftmargin{#1} }
  }
}

\cs_new:Nn \terms_set_spaces:
{
  \skip_set:Nn \partopsep { 0pt }
  \skip_set_eq:NN \topsep \l_terms_topsep
  \skip_set_eq:NN \itemsep \l_terms_itemsep
  \skip_set:Nn \listparindent { 0pt }
  \bool_if:NTF \l_terms_newline_bool
  {
    %\dim_set:Nn \labelwidth { 0pt }
    \dim_set_towidth:Nn \labelwidth {\l_terms_marker}
    \skip_set_eq:NN \partopsep \hzparskip
  }
  {
    \bool_if:NTF \l_terms_multiline_bool
    {
      \dim_set_eq:NN \labelwidth \l_terms_labelwidth
    }
    {
      \dim_set_towidth:Nn \labelwidth {\l_terms_marker\l_terms_font\l_terms_base\l_terms_delimiter}
    }
  }
  \skip_set_eq:NN \labelsep \l_terms_labelsep
  \terms_leftmargin:n {\l_terms_offset}
}

\cs_new:Npn \terms_label_default:n #1
{
  \int_gincr:N \l_terms_int
  \bool_if:NT \l_terms_indexing_bool { \index{#1} }
  \group_begin:
    \color{\l_terms_color}
    \l_terms_marker
    \l_terms_font #1
  \group_end:
  \l_terms_delimiter
}

\cs_new:Npn \terms_label_multiline:n #1
{
  \int_gincr:N \l_terms_int
  \bool_if:NT \l_terms_indexing_bool { \index{#1} }
  \hbox_set:Nn \l_tmpa_box {
  \parbox[t]{\labelwidth}{
    \raggedright
    \color{\l_terms_color}
    \l_terms_font #1
  }}
  \hbox_set:Nn \l_tmpb_box {\l_terms_font A}
  \dim_set:Nn \l_tmpa_dim { \box_ht:N \l_tmpb_box }
  \raisebox{\l_tmpa_dim}{ \smash{\box_use:N \l_tmpa_box} }
}

\cs_new:Npn \terms_label_newline:n #1
{
  \int_gincr:N \l_terms_int
  \bool_if:NT \l_terms_indexing_bool { \index{#1} }
  \parbox[b]{\labelwidth}{
    \makebox[0pt][l]{
      \color{\l_terms_color}
      \l_terms_marker
      \l_terms_font #1
      \l_terms_delimiter
    }
    \newline
  }
}

\NewDocumentEnvironment { terms } { s t{|} o }
{
  \IfBooleanT {#1} { \exp_args:No \TermsSetup{\l_terms_star} }
  \IfBooleanT {#2} { \exp_args:No \TermsSetup{\l_terms_vbar} }
  \IfValueT {#3} { \TermsSetup{#3} }
  \begin{list}{}
  {
    \bool_if:NT \l_terms_enumerate_bool
    {
      \tl_set:Nn \l_terms_marker_i {\int_use:N \l_terms_int)\hskip\l_terms_markersep}
      \int_gzero:N \l_terms_int
    }
    \terms_set_spaces:
    \cs_set_eq:NN \makelabel \terms_label_default:n
    \bool_if:NT \l_terms_newline_bool
    {
      \cs_set_eq:NN \makelabel \terms_label_newline:n
    }
    \bool_if:NT \l_terms_multiline_bool
    {
      \cs_set_eq:NN \makelabel \terms_label_multiline:n
    }
  }
}
{
  \end{list}
}

\cs_new:Npn \cmds_label_default:n #1
{
  \group_begin:
    \color{\l_terms_color}
    \l_terms_marker
    \texui{#1}
  \group_end:
  \l_terms_delimiter
}

\NewDocumentEnvironment {cmds} { O{} }
{
  \begin{terms}[#1]
  \cs_set_eq:NN \makelabel \cmds_label_default:n
}
{
  \end{terms}
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
}
{
  \end{list}
}

\NewDocumentCommand \AlignTerms { o m }
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

\NewEnviron{terms+}[1][]{ \AlignTerms[#1]{\BODY} }

\NewDocumentEnvironment { UI } { s t{|} } % a variant of terms
{
  \group_begin:
  \exp_args:No \TermsSetup{\l_UI_default}
  \IfBooleanT {#1} { \exp_args:No \TermsSetup{\l_UI_star} }
  \IfBooleanT {#2} { \exp_args:No \TermsSetup{\l_UI_vbar} }
  \IfBooleanTF {#1}
  {
    \IfBooleanTF {#2}
      { \begin{terms}*| }
      { \begin{terms}* }
  }
  {
    \IfBooleanTF {#2}
      { \begin{terms}| }
      { \begin{terms} }
  }
  \cs_set_eq:NN \uitem \item
  \cs_set_eq:NN \mitem \item
}
{
  \end{terms}
  \group_end:
}

\NewDocumentCommand \imgitem { m }
{
  \item[\lineimg{#1}]
}

\tl_new:N \l_symbol_options
\NewDocumentCommand \SymbolSetup { m }
{
  \tl_set:Nn \l_symbol_options {#1}
}

% a variant of the terms environment
\NewDocumentEnvironment { Symbol } { s o } 
{
  \group_begin:
  \IfBooleanT {#1}
  {
    \object_skip_before:n {0pt}
    \begin{RuleBox}[breakable=true]
  }
  \exp_args:No \TermsSetup{\l_symbol_options}
  \IfValueT {#2} { \TermsSetup{base=\lineimg{#2}} }
  \begin{terms}[index=false]
}
{
  \end{terms}
  \IfBooleanT {#1}
  {
    \end{RuleBox}
    \object_skip_after:n {0pt}
  }
  \group_end:
}

\SymbolSetup{itemsep=1ex, delimiter=\hfill}

% option list
\cs_new_nopar:Nn \opt_selected: { \foreign*{2611} }
\cs_new_nopar:Nn \opt_unselected: { \foreign*{2610} }
\cs_new_nopar:Nn \opt_label:
{
  \int_gincr:N \l_tmpa_int
  \clist_if_in:NoTF \l_tmpa_clist {\int_use:N \l_tmpa_int}
    {\opt_selected:}
    {\opt_unselected:}
}

\NewDocumentEnvironment { opt } { s O{} }
{
  \clist_set:Nn \l_tmpa_clist { #2 }
  \int_zero:N \l_tmpa_int
  \begin{list} {}
  {
    \IfValueT {#1} { \tightlist }
    \cs_set_eq:NN \makelabel \opt_label:
  }
}
{
  \end{list}
}

\NewDocumentEnvironment { opt* } { m }
  { \begin{ opt } { #1 } \tightlist }
  { \end{opt} }

% callout list
\int_new:N \l_callout_int
\tl_new:N \l_callout_label
\tl_set:Nn \l_callout_label {\calloutno}

\NewDocumentCommand \calloutno {}
{
  \int_to_arabic:n { \l_callout_int }
}

\keys_define:nn {callout}
{
  beforeskip  .skip_set:N = \l_callout_before_skip,
  afterskip   .skip_set:N = \l_callout_after_skip,
  column      .int_set:N = \l_callout_column,
  font        .tl_set:N = \l_callout_font,
  label       .tl_set:N = \l_callout_label,
  labelenum   .tl_set:N = \l_callout_label_enum,
  tab         .bool_set:N = \l_callout_tab_bool,
  space       .skip_set:N = \l_callout_space,
  bar         .bool_set:N = \l_callout_bar_bool
}

\NewDocumentCommand \CalloutSetup {m}
{
  \keys_set:nn {callout} {#1}
}

\CalloutSetup{
  beforeskip=.25\baselineskip,
  afterskip=.75\baselineskip,
  column=3,
  font=\small,
  label={\makebox[1.25em]{\hfill\calloutno)}\enspace},
  labelenum=\theenumi),
  tab=true,
  space=0.25em
}
%label=\cirnum{\calloutno}

\cs_new:Nn \callout_item_tab:
{
  \int_gincr:N \l_callout_int
  \int_compare:nTF { \l_callout_int > 1 }
  {
    \int_set:Nn \l_tmpa_int {\int_mod:nn {\l_callout_int} {\l_callout_column} }
    \int_compare:nT { \l_tmpa_int = 1 }
      {\newline}
      {\tab}
  }
  {
    \noindent
  }
  \l_callout_label
}

\cs_new:Nn \callout_item_space:
{
  \int_gincr:N \l_callout_int
  \int_compare:nT { \l_callout_int > 1 } {\hskip\l_callout_space}
  \l_callout_label
}

\NewDocumentEnvironment {callout} { s o }
{
  \object_skip_before:n {\l_callout_before_skip}
  \begin{RuleBox}
  \setfootnoterule{0pt}{0pt}{0pt}
  \l_callout_font
  %\IfBooleanT {#1} { \int_set:Nn \l_callout_column {1}  }
  \IfBooleanTF {#1}
  {
    \renewcommand\labelenumi{\l_callout_label_enum}
    \begin{enumerate}
    \tightlist\HzJustification
  }{
    \IfValueT {#2} { \int_set:Nn \l_callout_column {#2} }
    \NumTabs {\l_callout_column}
    \int_zero:N \l_callout_int
    \bool_if:NTF \l_callout_tab_bool
      {\cs_set_eq:NN \item \callout_item_tab:}
      {\cs_set_eq:NN \item \callout_item_space:}
  }
}
{
  \IfBooleanT {#1} { \end{enumerate}  }
  \end{RuleBox}
  \object_skip_after:n {\l_callout_after_skip}
}

% circled number

\ExplSyntaxOff
\usetikzlibrary{shapes}
\ExplSyntaxOn

\NewDocumentCommand\cirnumdraw{mmmmmmm}
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
  \dim_set_towidth:Nn \l_cirnum_width_dim{\l_cirnum_font_feature\l_cirnum_font #1}
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
  sep=0.1pt,
  raise=-.5ex,
  base=10
}

\CirnumSetup{fontfeature={\addfontfeature{LetterSpace=-3}}}

\cs_new_eq:NN \cirnumsetup \CirnumSetup

\NewDocumentCommand \cirnum {m}
{
  \cirnumdraw
    {\l_cirnum_raise_dim}
    {\l_cirnum_fgcolor}
    {\l_cirnum_sep_dim}
    {\l_cirnum_bgcolor}
    {\l_cirnum_width_dim}
    {\l_cirnum_font_feature\l_cirnum_font}
    {#1}
}

\ExplSyntaxOff

% literal
\def\tmpfile{tempverb.tex}
% Leave nothing behind \end{SaveVerb} in the same line
\def\SaveVerb{%
  \@bsphack
  \immediate\openout \verbatim@out \tmpfile
  \let\do\@makeother\dospecials
  \catcode`\^^M\active
  \def\verbatim@processline{%
    \immediate\write\verbatim@out
      {\the\verbatim@line}}%
  \verbatim@start}
\def\endSaveVerb{%
  \immediate\closeout\verbatim@out
  \@esphack}

\ExplSyntaxOn

\newcommand\VerbFont{\ttfamily\hyphenpenalty 10000}

%inputref
\NewDocumentCommand \inputasis { s }
{
  \object_skip_before:n {\l_admonition_before_skip}
  \ior_open:Nn \l_txt_io { \tmpfile }
  \begin{AdmonBox}
    \VerbFont
    \ior_map_inline:Nn \l_txt_io
    {
      ##1
      \newline
    }
  \vspace{-\baselineskip}
  \end{AdmonBox}
  \ior_close:N \l_txt_io
  \object_skip_after:n {\l_admonition_after_skip}
}

\NewDocumentCommand \verbline { v }
{
  \object_skip_before:n {\l_admonition_before_skip}
  \begin{AdmonBox}
    \VerbFont #1
  \end{AdmonBox}
  \object_skip_after:n {\l_admonition_after_skip}
}

\cs_set_eq:NN \cmdline \verbline

\tcbuselibrary{breakable,skins}
\tcbset{enhanced}

\newtcolorbox{LeftBarBox}{
  before~skip=0pt, after~skip=0pt, breakable=false,
  colframe=white, colback=white, arc=0ex, boxrule=0pt,
  boxsep=0pt, top=0pt, bottom=0pt, left=1.5em, right=0em,
  borderline~west={1.5pt}{0pt}{gray}
}

\newtcolorbox{RightBarBox}{
  before~skip=0pt, after~skip=0pt, breakable=false,
  colframe=white, colback=white, arc=0ex, boxrule=0pt,
  boxsep=0pt,  top=0pt, bottom=0pt, left=3em, right=1.5em,
  borderline~east={1.5pt}{0pt}{gray}
}

\newtcolorbox{ShadowBox}{
  before~skip=0pt, after~skip=0pt,
  boxrule=0.5pt, colframe=darkgray, colback=white, arc=0.5ex,
  boxsep=0.25ex, top=0.75ex, bottom=0.75ex, left=0.5em, right=0.5em,
  drop~fuzzy~shadow={scale=2}, breakable=true,
}

\newtcolorbox{UnbreakableShadeBox}[1][]{
  before~skip=0pt, after~skip=0pt,
  width=\linewidth-\l_admonition_indent_skip,
  boxrule=0.75pt, colframe=white, colback=backgray, arc=0.5ex,
  boxsep=0.25ex, top=0.75ex, bottom=0.75ex, left=0.5em, right=0.5em,
  titlerule=0.75pt, toptitle=-0.25ex, bottomtitle=0.5ex,
  colbacktitle=lightgray, coltitle=black,
  fonttitle=\bfseries, breakable=false, title=#1
}

\newtcolorbox{BreakableShadeBox}[1][]{
  before~skip=0pt, after~skip=0pt,
  boxrule=0.75pt, colframe=white, colback=backgray, arc=0.5ex,
  boxsep=0.25ex, top=0.75ex, bottom=0.75ex, left=0.5em, right=0.5em,
  titlerule=0.75pt, toptitle=0.5ex, bottomtitle=0.5ex,
  colbacktitle=lightgray, coltitle=black,
  fonttitle=\bfseries, breakable=true, title=#1
}

\newtcolorbox{RuleBox}[1][]{
  before~skip=0pt, after~skip=0pt, breakable=false,
  colframe=white, colback=white, arc=0ex, boxrule=0pt,
  boxsep=0.25ex,  top=0.75ex, bottom=0.75ex, left=0em, right=0em,
  borderline~north={0.5pt}{0pt}{darkgray},
  borderline~south={0.5pt}{0pt}{darkgray}, #1
}

\newtcolorbox{TabBox}[1][]{
  enhanced,
  before~skip=0pt, after~skip=0pt,
  boxrule=0.5pt, colframe=gray, colback=white, arc=0.5ex,
  boxsep=.5ex, top=1.5ex, bottom=0.5ex, left=0.5em, right=0.5em,
  colbacktitle=white, coltitle=black,
  attach~boxed~title~to~top~left={xshift=.5cm, yshift=-1.75mm},
  boxed~title~style={size=minimal, enhanced, boxrule=0.25pt, colframe=white},
  fonttitle=\bfseries, breakable=\FrameBreakable, title={\space #1 \space}
}

% signal words
% Admonition*: without linespacing before and after
% Admonition|: the frame becomes breakable when the frame option is globally set to being unbreakable, or the other way.

\NewDocumentEnvironment { admonition } { s t{|} m o }
{
  \group_begin:
  \IfBooleanT {#2}
  {
    \str_if_eq:VnTF \l_admonition_type {BreakableShade}
      { \AdmonitionSetup{type=UnBreakableShade} }
      { \AdmonitionSetup{type=BreakableShade} }
  }
  \IfValueT {#4} { \AdmonitionSetup{#4} }
  \IfBooleanF {#1} { \object_skip_before:n {\l_admonition_before_skip} }
  \begin{AdmonBox} [#3] \l_admonition_style
}
{
  \end{AdmonBox}
  \IfBooleanF {#1} { \object_skip_after:n {\l_admonition_after_skip} }
  \group_end:
}

\tl_new:N \l_admonition_type
\cs_new:Npn \admonition_type:n #1
{
  \tl_set:Nn \l_admonition_type {#1}
  \str_case:nn {#1}
  {
    {BreakableShade}  {
      \cs_set_eq:NN \AdmonBox \BreakableShadeBox
      \cs_set_eq:NN \endAdmonBox \endBreakableShadeBox
    }
    {UnbreakableShade}  {
      \cs_set_eq:NN \AdmonBox \UnbreakableShadeBox
      \cs_set_eq:NN \endAdmonBox \endUnbreakableShadeBox
    }
    {tab}   {
      \cs_set_eq:NN \AdmonBox \TabBox
      \cs_set_eq:NN \endAdmonBox \endTabBox
    }
  }
}

\tl_new:N \l_admonition_style
\tl_new:N \l_admonition_style_basic
\tl_set:Nn \l_admonition_style {
  \HzJustification
  \l_admonition_style_basic
  \l_admonition_style_extra
}

\keys_define:nn {admonition}
{
  beforeskip  .skip_set:N = \l_admonition_before_skip,
  afterskip   .skip_set:N = \l_admonition_after_skip,
  indent      .skip_set:N = \l_admonition_indent_skip,
  type        .code:n = { \admonition_type:n {#1} },
  symbol      .tl_set:N = \l_admonition_symbol,
  danger      .tl_set:N = \l_admonition_danger,
  warning     .tl_set:N = \l_admonition_warning,
  caution     .tl_set:N = \l_admonition_caution,
  notice      .tl_set:N = \l_admonition_notice,
  note        .tl_set:N = \l_admonition_note,
  style       .tl_set:N = \l_admonition_style_extra
}

\NewDocumentCommand \AdmonitionSetup { m }
{
  \keys_set:nn {admonition} {#1}
}

\AdmonitionSetup {
  beforeskip=0pt,
  afterskip=0pt,
  indent=0pt,
  type=UnbreakableShade,
  symbol = {\lineimg{AlertSymbol}~},
  danger = DANGER,
  warning = WARNING,
  caution = CAUTION,
  notice = NOTICE,
  note = NOTE,
}


\tl_new:N \l_reference_style

\NewDocumentCommand \ReferenceSetup { m }
{
  \tl_set:Nn \l_reference_style { #1 }
}

\NewDocumentEnvironment { reference } { s t{|} }
{
  \group_begin:
  \IfBooleanT {#2} { \wrappingon } % for verbatim
  \exp_args:No \AdmonitionSetup{ \l_reference_style }
  \IfBooleanTF {#1}
  {
    \begin{IfVartwoEnlarge}
  }{
    \object_skip_before:n {\l_admonition_before_skip}
  }
  \begin{AdmonBox}
  \l_admonition_style
}{
  \end{AdmonBox}
  \IfBooleanTF {#1}
  {
    \end{IfVartwoEnlarge}
  }{
    \object_skip_after:n {\l_admonition_after_skip}
  }
  \group_end:
}


\NewDocumentEnvironment { Danger } { s t{|} }
{
  \IfBooleanTF{#1}
  {
    \IfBooleanTF{#2}
    { \begin{admonition}*|{\l_admonition_symbol\l_admonition_danger} }
    { \begin{admonition}*{\l_admonition_symbol\l_admonition_danger} }
  }{
  \IfBooleanTF{#2}
    { \begin{admonition}|{\l_admonition_symbol\l_admonition_danger} }
    { \begin{admonition}{\l_admonition_symbol\l_admonition_danger} }
  }
}{
  \end{admonition}
}


\NewDocumentEnvironment { Warning } { s t{|} }
{
  \IfBooleanTF{#1}
  {
    \IfBooleanTF{#2}
    { \begin{admonition}*|{\l_admonition_symbol\l_admonition_warning} }
    { \begin{admonition}*{\l_admonition_symbol\l_admonition_warning} }
  }{
  \IfBooleanTF{#2}
    { \begin{admonition}|{\l_admonition_symbol\l_admonition_warning} }
    { \begin{admonition}{\l_admonition_symbol\l_admonition_warning} }
  }
}{
  \end{admonition}
}

\NewDocumentEnvironment { Caution } { s t{|} }
{
  \IfBooleanTF{#1}
  {
    \IfBooleanTF{#2}
    { \begin{admonition}*|{\l_admonition_symbol\l_admonition_caution} }
    { \begin{admonition}*{\l_admonition_symbol\l_admonition_caution} }
  }{
  \IfBooleanTF{#2}
    { \begin{admonition}|{\l_admonition_symbol\l_admonition_caution} }
    { \begin{admonition}{\l_admonition_symbol\l_admonition_caution} }
  }
}
{
  \end{admonition}
}


\NewDocumentEnvironment { Notice } { s t{|} }
{
  \IfBooleanTF{#1}
  {
    \IfBooleanTF{#2}
    { \begin{admonition}*|{\l_admonition_notice} }
    { \begin{admonition}*{\l_admonition_notice} }
  }{
  \IfBooleanTF{#2}
    { \begin{admonition}|{\l_admonition_notice} }
    { \begin{admonition}{\l_admonition_notice} }
  }
}{
  \end{admonition}
}


\NewDocumentEnvironment { Note } { s t{|} }
{
  \IfBooleanTF{#1}
  {
    \IfBooleanTF{#2}
    { \begin{admonition}*|{\l_admonition_note} }
    { \begin{admonition}*{\l_admonition_note} }
  }{
  \IfBooleanTF{#2}
    { \begin{admonition}|{\l_admonition_note} }
    { \begin{admonition}{\l_admonition_note} }
  }
}{
  \end{admonition}
}

\keys_define:nn {instance}
{
  beforeskip  .dim_set:N = \l_instance_before_skip,
  afterskip  .dim_set:N = \l_instance_after_skip,
  type       .code:n = { \instance_type:n {#1} },
  fontcolor  .tl_set:N = \l_instance_fontcolor,
  style    .tl_set:N = \l_instance_style
}

\NewDocumentCommand \InstanceSetup { m }
{
  \keys_set:nn {instance} {#1}
}

\tl_new:N \l_instance_type
\cs_new:Npn \instance_type:n #1
{
  \tl_set:Nn \l_instance_type {#1}
  \str_case:nn {#1}
  {
    {LeftBar}  {
      \cs_set_eq:NN \InstanceBox \LeftBarBox
      \cs_set_eq:NN \endInstanceBox \endLeftBarBox
    }
    {RightBar}  {
      \cs_set_eq:NN \InstanceBox \RightBarBox
      \cs_set_eq:NN \endInstanceBox \endRightBarBox
    }
    {Shadow}  {
      \cs_set_eq:NN \InstanceBox \ShadowBox
      \cs_set_eq:NN \endInstanceBox \endShadowBox
    }
  }
}

\InstanceSetup{
  beforeskip = 1.25\baselineskip,
  afterskip = 1.25\baselineskip,
  type = RightBar,
  fontcolor = black
}

\NewDocumentEnvironment {instance} {}
{
  \object_skip_before:n {\l_instance_before_skip}
  \begin{InstanceBox}
  \color{\l_instance_fontcolor}
  \l_instance_style
}{
  \end{InstanceBox}
  \object_skip_after:n {\l_instance_after_skip}
}

\cs_set_eq:NN \Reference \reference
\cs_set_eq:NN \endReference \endreference
\cs_set_eq:NN \Instance \instance
\cs_set_eq:NN \endInstance \endinstance

\NewDocumentCommand \SetEmphasisAs { m }
{
  \str_case:nn {#1}
  {
    { reference } {
      \cs_set_eq:NN \emphasis \reference
      \cs_set_eq:NN \endemphasis \endreference
    }
    { instance} {
      \cs_set_eq:NN \emphasis \instance
      \cs_set_eq:NN \endemphasis \endinstance
    }
  }
}

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

\NewDocumentCommand \WatermarkSetup {m}
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

\NewDocumentCommand \watermark {m}
{
  \ClearWatermark
  \WatermarkSetup {#1}
  \bool_if:NTF \l_watermark_text_type
    {\watermark_text: }
    {\watermark_image: }
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
    { \subsection*{#2} }
    { \subsubsection*{#2} }
  \addcontentsline{lop}{problem}{#2}
}

\NewDocumentCommand \ProblemSetup { m }
{
  \keys_set:nn { problem } { #1 }
}

\ProblemSetup{
%  name = {List~of~Problems},
  style = \section*{\ProblemListName}
}

% miscellaneous utilities * * * * * * * * * * * * * * * * * * * * * * * * * * *

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

%\renewcommand\UrlFont{\sffamily}

\NewDocumentCommand \email { m }
{
  \href{mailto:#1}{\nolinkurl{#1}}
}

\NewDocumentCommand \URL { s m }
{
  \IfBooleanTF {#1}
  { \href{http://#2}{\nolinkurl{#2}}  }
  { \url{#2} }
}

\NewDocumentCommand \skiplines { O {1} }
{
  \vspace{#1\baselineskip}
}

\keys_define:nn { wraprule }
{
  gap      .tl_set:N = \l_wraprule_gap,
  thickness  .tl_set:N = \l_wraprule_thickness,
  raise    .dim_set:N = \l_wraprule_raise
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
  star        .tl_set:N = \l_annotate_star,
}

\NewDocumentCommand \AnnotateSetup { m }
{
  \keys_set:nn { annotate } {#1}
}

\AnnotateSetup{
  breakable=true,
  superscript=true,
  font=\footnotesize,
  color=darkgray,
  space=\thinspace,
  opening=(,
  closing=),
  raise=0.75ex,
  star={superscript=false, font=\scriptsize, raise=0.25ex}
}

\NewDocumentCommand \annotate { s t{|} O{} m }
{
  \IfBooleanT {#1}
    { \exp_args:No \AnnotateSetup{\l_annotate_star} }
  \IfBooleanT {#2}
    { \AnnotateSetup{breakable=false} }
  \AnnotateSetup{#3}
     \l_annotate_space
     \bool_if:NTF \l_annotate_breakable_bool
     {
       \exp_args:Nx \annotate_scope:n {\l_annotate_opening #4 \l_annotate_closing}
     }{
       \annotate_display_unbreakable:n {\l_annotate_opening #4 \l_annotate_closing}
     }
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
    \annotate_display_breakable:V \l_annotate_tl
    \tl_clear:N \l_annotate_tl
    \peek_catcode:NTF \c_space_token
    {
      \space\annotate_recur:n
    }{
      \annotate_recur:n
    }
  }
}

\cs_new:Npn \annotate_display_breakable:V #1
{
  \group_begin:
    \l_annotate_font
      \color{\l_annotate_color}
    \bool_if:NTF \l_annotate_superscript_bool
      { \raisebox{\l_annotate_raise}{#1} }
      { \raisebox{-\l_annotate_raise}{#1} }
  \group_end:
}

\cs_new:Npn \annotate_display_unbreakable:n #1
{
  \bool_if:NTF \l_annotate_superscript_bool
  {
    \textsuperscript{\textcolor{\l_annotate_color}{\l_annotate_font #1}}
  }{
    \textsubscript{\textcolor{\l_annotate_color}{\l_annotate_font #1}}
  }
}

%\exp_args:No \ItemizeOnRight{\csv}[\font]
\NewDocumentCommand \ItemizeOnRight { m O{} }
{
  \tl_if_empty:nF {#1}
  {
    \dim_zero:N \l_tmpa_dim
    \dim_zero:N \l_tmpb_dim
    \tl_clear:N \l_tmpa_tl
    \exp_args:No \clist_map_inline:nn {#1}
    {
      \tl_put_right:Nn \l_tmpa_tl {##1\newline}
      \dim_set_towidth:Nn \l_tmpb_dim {#2 ##1}
      \dim_compare:nT { \l_tmpa_dim < \l_tmpb_dim }
      {
        \dim_set_eq:NN \l_tmpa_dim \l_tmpb_dim
      }
    }
    \hfill
    \begin{minipage}{\l_tmpa_dim}
      #2 \l_tmpa_tl
    \end{minipage}
  }
}

% scenario
\seq_new:N \g_scenario_text_seq
\cs_new:Npn \scenario_add_text:n #1
{
  \seq_gput_right:Nn \g_scenario_text_seq {#1}
}

\group_begin:
\char_set_catcode_space:n {`\ }
\scenario_add_text:n {Lorem ipsum dolor sit amet, consectetuer adipiscing elit. }
\scenario_add_text:n {Etiam lobortis facilisis sem. Nullam nec mi et neque pharetra sollicitudin. Praesent imperdiet mi nec ante. }
\scenario_add_text:n {Donec ullamcorper, felis non sodales commodo, lectus velit ultrices augue, a dignissim nibh lectus placerat pede. Vivamus nunc nunc, molestie ut, ultricies vel, semper in, velit. Ut porttitor. Praesent in sapien. Lorem ipsum dolor sit amet, consectetuer adipiscing elit. Duis fringilla tristique neque. }
\scenario_add_text:n {Sed interdum libero ut metus. Pellentesque placerat. Nam rutrum augue a leo. Morbi sed elit sit amet ante lobortis sollicitudin. Praesent blandit blandit mauris. Praesent lectus tellus, aliquet aliquam, luctus a, egestas a, turpis. Mauris lacinia lorem sit amet ipsum. Nunc quis urna dictum turpis accumsan semper.}
\group_end:

\cs_new:Npn \scenario_print_text:n #1
{
  \seq_item:Nn \g_scenario_text_seq {#1}
}

\NewDocumentCommand \scenetext { O{1} }
{
  \int_step_function:nnnN {1}{1}{#1} \scenario_print_text:n
}

\NewDocumentCommand \scenepara { s }
{
  \IfBooleanTF {#1}
    { \scenetext[3] }
    { \scenetext[2]  }
  \par
}

% \scenelist*[terms][enumerate]

\NewDocumentCommand \scenelist { s o o }
{
  \scenepara
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
    { \scenario_list:nn {\l_tmpa_str}{#3} }
    { \scenario_list:nn {\l_tmpa_str}{} }
}

\cs_new:Npn \scenario_list:nn #1 #2
{
  \begin{#1}
  \int_zero:N \l_tmpa_int
  \int_do_while:nNnn {\l_tmpa_int} < {4}
  {
    \int_incr:N \l_tmpa_int
    \str_if_eq_x:nnTF {terms} {#1}
      { \scenario_item_label: {#2} }
      { \scenario_item: {#2} }
  }
  \end{#1}
}

\cs_new:Npn \scenario_item_label: #1
{
  \tl_set:Nn \l_tmpa_tl {Term~\int_to_Alph:n {\l_tmpa_int}}
  \item[\l_tmpa_tl] \scenetext
  \tl_if_empty:nF {#1} { \scenario_list:nn {#1}{} }
}

\cs_new:Npn \scenario_item: #1
{
  \item \scenetext
  \tl_if_empty:nF {#1} { \scenario_list:nn {#1}{} }
}

\NewDocumentCommand \sceneimage {}
{
  \par\placeimage{uncertain}
}

\NewDocumentCommand \scenelineimg {}
{
  \lineimg{uncertain}
}

\NewDocumentCommand \sceneimagetable {}
{
  \scenepara
  \par
  \begin{ImageTable}
    \scenelineimg & \scenelineimg & \scenelineimg \\
    First~item & Second~item & Third~item \\
    \scenelineimg & \scenelineimg & \scenelineimg \\
    Fourth~item & Fifth~item & Sixth~item \\
  \end{ImageTable}
}

\NewDocumentCommand \sceneprocedure { O{3} }
{
  \int_set:Nn \l_tmpa_int {1}
  \int_set:Nn \l_tmpb_int {#1}
  \scenepara
  \par\illuenum*{uncertain}{\item \scenepara}
  \int_do_while:nNnn {\l_tmpa_int} < {\l_tmpb_int}
    {
      \int_incr:N \l_tmpa_int
      \par\illuenum{uncertain}{\item \scenepara}
    }
}

\NewDocumentCommand \scenetasks { O{5} }
{
  \int_set:Nn \l_tmpa_int {0}
  \int_set:Nn \l_tmpb_int {#1}
  \int_do_while:nNnn {\l_tmpa_int} < {\l_tmpb_int}
  {
    \int_incr:N \l_tmpa_int
    \str_set:Nx \l_tmpa_str { \int_to_Alph:n \l_tmpa_int }
    \section{Task~\l_tmpa_str}
    \scenelist*

  }
}

\NewDocumentCommand \scenespectable {}
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

\NewDocumentCommand \scenespectables { O{3} }
{
  \int_step_inline:nnnn {1}{1}{#1}{ \scenespectable }
}

\NewDocumentCommand \scenetable {}
{
  \par
  \begin{PlaceTable}
    \begin{tabu}{X[lp]X[lp]X[lp]}\hline
      \rowfont{\bfseries} A & B & C \\\hline
      1 & 1 & 1\\
      2 & 2 & 2\\
      3 & 3 & 3\\
      4 & 4 & 4\\
      5 & 5 & 5\\
    \hline\end{tabu}
  \end{PlaceTable}
}

\NewDocumentCommand \sceneproblem {}
{
  \problem{Problem} \scenepara
}

\NewDocumentCommand \sceneproblems { O{3} }
{
  \listofproblems*
  \int_set:Nn \l_tmpa_int {0}
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
          \scenepara*
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
  \RenewDocumentCommand \addcontentsline {mmm}
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

% verbatim --------------------------------------------------------------------

\RenewDocumentCommand \verb {v} {
  \texttt{#1}
}

\NewDocumentCommand \texui { s m }
{
  \tl_if_head_eq_catcode:nNTF {#2} \
  {
    \tl_set:Nx \l_tmpa_tl { \cs_to_str:N #2 }
    \tl_set:Nx \l_tmpb_tl { \tl_to_str:N \l_tmpa_tl }
    \IfBooleanF {#1}
      { \index{\l_tmpb_tl @ \textbackslash\ToString{\l_tmpb_tl}} }
    \texttt{\textbackslash\l_tmpb_tl}
  }
  {
    \IfBooleanF {#1} { \index{#2} }
    \texttt{#2}
  }
}

\NewDocumentCommand \verbshow { s }
{
  \bool_if:NTF \g_verbatim_bool
  {
    \inputminted{latex}{\tmpfile}
  }{
    \boxedverbatiminput{\tmpfile}
  }
  \object_skip_before:n {0pt}
  \begin{RightBarBox}
    \sffamily \input{\tmpfile}
  \end{RightBarBox}
  \object_skip_after:n {0pt}
}

\NewDocumentCommand \inputverb { s }
{
  \IfBooleanF {#1}
    { \object_skip_before:n {0pt} }
  \begin{RightBarBox}
    \sffamily \input{\tmpfile}
  \end{RightBarBox}
  \IfBooleanF {#1}
    { \object_skip_after:n {0pt} }
}

\NewDocumentCommand \showtex { s }
{
  \IfBooleanTF { #1 }
  {
    \object_skip_before:n {0pt}
    \begin{IfVartwoEnlarge}\noindent
      \begin{minipage}{.48\linewidth}
          \inputminted{latex}{\tmpfile}
      \end{minipage}
      \hfill
      \begin{minipage}{.48\linewidth}
        \inputverb*
      \end{minipage}
    \end{IfVartwoEnlarge}
    \object_skip_after:n {0pt}
  }
  {
    \inputminted{latex}{\tmpfile}
  }
}

\ExplSyntaxOff

% default setup * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% font
\setmainfont{TeX Gyre Pagella}
\setsansfont{TeX Gyre Heros}
\setmonofont[AutoFakeBold=1.25]{Latin Modern Mono}

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
%\setlength\cftsubsectionindent{0em}
%\setlength\cftsubsectionnumwidth{3.5em}

% justification & alignment
% Use \RaggedRight instead of \raggedright when using bidi
\sloppy
\raggedbottom

% colors
\definecolor{backgray}{gray}{0.9}

\LoadStyleset

% cross-reference
\renewcommand{\chapterrefname}{\chaptername~}
\renewcommand{\tablerefname}{\tablename}
\renewcommand{\figurerefname}{\figurename}

\@ifpackageloaded{minted}{
  \setminted{encoding=UTF8, fontsize=\small, tabsize=2, breaklines=true, linenos=false, frame=single}
  \patchcmd{\FV@ListVSpace}{\@topsepadd\topsep}{\vspace{.25\baselineskip}}{}{}
}{}

% index
\endinput

% how to use different fonts for the same font command
\newhangulfontfamily\gungseo{GungSeo}[SlantedFont=*]
\newhangulfontfamily\pilgi{Pilgi}[ItalicFont=*]
\edef\slshape{\unexpanded\expandafter{\slshape\gungseo}}
\edef\itshape{\unexpanded\expandafter{\itshape\pilgi}}
