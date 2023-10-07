% Variables beginning with "Hz" or "hz" are intended to be effective through the entire document.
% Obey these naming rules for commands, environments, variables, and parameter keys.
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

% A memoir-based class for techincal writers
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{hzguide}[2022/03/18 v2.1.0]

\LoadClassWithOptions{memoir}

\RequirePackage{l3keys2e}
\RequirePackage{etoolbox}
\RequirePackage{calc}

\RequirePackage{fontspec}
% \RequirePackage{ragged2e}
\RequirePackage[shortlabels]{enumitem}
\RequirePackage{tabto}
\RequirePackage[normalem]{ulem}
\RequirePackage{xspace}

\RequirePackage[svgnames,x11names,dvipsnames,hyperref,table]{xcolor}
\RequirePackage{graphicx}
\RequirePackage{eso-pic}

\RequirePackage{tabularray}

\RequirePackage[obeyspaces, spaces]{url}
\RequirePackage{hyperref}
\RequirePackage{bookmark}

\RequirePackage{tikz}
\RequirePackage{tikzpagenodes}
\RequirePackage{tcolorbox}
\RequirePackage[os=win]{menukeys}

\usetikzlibrary{shapes}
\usetikzlibrary{shadows}
\tcbuselibrary{breakable, skins, xparse}
\tcbset{enhanced}

\ExplSyntaxOn

% # global variables

\newfontfamily\symbolfont{NotoSansSymbols-Regular.ttf}[BoldFont=NotoSansSymbols-Bold.ttf]
\DeclareTextFontCommand{\textsb}{\symbolfont}

% ^^^^ac00 ^^^^^^020000
% \char44032 \char"AC00 \char'126000 \char`가 \char`^^^^ac00
% \newhangulfontfamily\gungseo{GungSeo}[SlantedFont=*]
% \newhangulfontfamily\pilgi{Pilgi}[ItalicFont=*]
% \edef\slshape{\unexpanded\expandafter{\slshape\gungseo}}
% \edef\itshape{\unexpanded\expandafter{\itshape\pilgi}}

\dim_new:N \hznulldim
\dim_set:Nn \hznulldim { -1000pt }

% # tools being used at the level of class __________________________________________________

\NewDocumentCommand \IfXetex { m o }
{
    \sys_if_engine_xetex:TF
    {
        #1
    }{
        \IfValueT{ #2 }{ #2 }
    }
}

\NewDocumentCommand \IfLuatex { m o }
{
    \sys_if_engine_luatex:TF
    {
        #1
    }{
        \IfValueT{ #2 }{ #2 }
    }
}

% ## conditional text

\cs_generate_variant:Nn \prg_set_conditional:Npnn { c }
\exp_args_generate:n { cnn }

% \NewConditionals{command}{setup}[environment]
\NewDocumentCommand \NewConditionals { m m o }
{
    \clist_new:c { g_#1_property_clist }

    \prg_set_conditional:cpnn { #1_if_in:n } ##1 { TF }
    {
        \clist_if_in:cnTF { g_#1_property_clist }{ ##1 }
        {
            \prg_return_true:
        }{
            \prg_return_false:
        }
    }

    \prg_set_conditional:cpnn { #1_if_or_in:nn } ##1 ##2 { TF }
    {
        \clist_if_in:cnTF { g_#1_property_clist}{ ##1 }
        {
            \prg_return_true:
        }{
            \clist_if_in:cnTF { g_#1_property_clist}{ ##2 }
            {
                \prg_return_true:
            }{
                \prg_return_false:
            }
        }
    }

    \prg_set_conditional:cpnn { #1_if_and_in:nn } ##1 ##2 { TF }
    {
        \clist_if_in:cnTF { g_doc_property_clist }{ ##1 }
        {
            \clist_if_in:cnTF { g_doc_property_clist}{ ##2 }
            {
                \prg_return_true:
            }{
                \prg_return_false:
            }
        }{
            \prg_return_false:
        }
    }

    \conditional_create_setup:nn { #1 }{ #2 }
    \conditional_create_command:n { #1 }
    \IfValueT { #3 }
    {
        \conditional_create_environment:nn { #1 }{ #3 }
    }
}

\cs_new:Npn \conditional_create_setup:nn #1 #2
{
    \exp_args:Ncnn \NewDocumentCommand { #2Setup } { s m }
    {
        \IfBooleanTF { ##1 }
        {
            \clist_set:cn { g_#1_property_clist }{ ##2 }
        }{
            \clist_gput_right:cn { g_#1_property_clist }{ ##2 }
        }
    }
}

% \ifxxx{foo}{TRUE}[FALSE]         : if "foo" is in; else
% \ifxxx^{foo}{TRUE}[FALSE]        : if "foo" is NOT in; else
% \ifxxx{foo}[goo]{TRUE}[FALSE]    : if "foo" or "goo" is in; else
% \ifxxx*{foo}[goo]{TRUE}[FALSE]   : if "foo" and "goo" are inin; else
\cs_new:Npn \conditional_create_command:n #1
{
    \exp_args:Ncnn \NewDocumentCommand { if#1 } { s t^ m o +m +o }
    {
        \IfBooleanTF { ##2 }
        {
            \use:c { #1_if_in:nTF } { ##3 }
            {
                \IfValueT { ##6 }{ ##6 }
            }{
                ##5
            }
        }{
            \IfValueTF { ##4 }
            {
                \IfBooleanTF { ##1 }
                {
                    \use:c { #1_if_and_in:nnTF } { ##3 }{ ##4 }
                    {
                        ##5
                    }{
                        \IfValueT { ##6 }{ ##6 }
                    }
                }{
                    \use:c { #1_if_or_in:nnTF } { ##3 }{ ##4 }
                    {
                        ##5
                    }{
                        \IfValueT { ##6 }{ ##6 }
                    }
                }
            }{
                \use:c { #1_if_in:nTF } { ##3 }
                {
                    ##5
                }{
                    \IfValueT { ##6 }{ ##6 }
                }
            }
        }
    }
}

% \begin{Ifxxx}{foo}         : if "foo" is in
% \begin{Ifxxx}^{foo}        : if "foo" is NOT in
% \begin{Ifxxx}{foo}[goo]    : if "foo" or "goo" is in
% \begin{Ifxxx}*{foo}[goo]   : if "foo" and "goo" are in
\cs_new:Npn \conditional_create_environment:nn #1 #2
{
    \NewDocumentEnvironment { If#2 }{ s t^ m o +b }
    {
        \IfBooleanTF { ##2 }
        {
            \use:c { #1_if_in:nTF } { ##3 } {}{ ##5 }
        }{
            \IfValueTF { ##4 }
            {
                \IfBooleanTF { ##1 }
                {
                    \use:c { #1_if_and_in:nnTF } { ##3 }{ ##4 } { ##5 }{}
                }{
                    \use:c { #1_if_or_in:nnTF } { ##3 }{ ##4 } { ##5 }{}
                }
            }{
                \use:c { #1_if_in:nTF } { ##3 } { ##5 }{}
            }
        }
    }{}
}

\NewConditionals{doc}{Document}[Doc]
\NewConditionals{Lang}{Language}[Language]

% english     ENGLISH
% chinese     中文
% czech       ČEŠTINA
% danish      DANSK
% dutch       NEDERLANDS
% finnish     SUOMI
% french      FRANÇAIS
% german      DEUTSCH
% italian     ITALIANO
% japanese    日本語
% korean      한국어
% norwegian   NORSK
% polish      POLSKI
% portuguese  PORTUGUÊS
% russian     РУССКИЙ ЯЗЫК
% slovak      SLOVENČINA
% spanish     ESPAÑOL
% swedish     SVENSKA
% turkish     TÜRKÇE
% TC          Traditional chinese


% # class options ______________________________________________________________________

\keys_define:nn { HzGuide }
{
    language    .code:n = { \LanguageSetup*{ #1 } },
    english     .code:n = { \LanguageSetup*{ english } },
    property    .clist_set:N = \g_doc_property_clist, 
    packageset  .tl_set:N = \g_package_set_tl,
    styleset    .tl_set:N = \g_style_set_tl,
    Noto        .bool_set:N = \g_Noto_bool,
    minted    	.bool_set:N = \g_minted_bool,
    pairquote   .bool_set:N = \g_pairquote_bool,
    template    .bool_set:N = \g_template_bool
}

\bool_new:N \g_CJK_bool
\bool_gset_false:N \g_CJK_bool

\NewDocumentCommand \ClassSetup { m }
{
    \keys_set:nn { HzGuide }{ #1 }
}

\NewDocumentCommand \LoadPackageSet {}
{
    \tl_if_empty:NF \g_package_set_tl
    {
        \input{ \g_package_set_tl }
    }
}

\NewDocumentCommand \LoadStyleset {}
{
    \tl_if_empty:NF \g_style_set_tl
    {
        \input{ \g_style_set_tl }
    }
}

% default class options
\ClassSetup{ language=korean }

\ProcessKeysOptions{ HzGuide }
\hypersetup{pdfencoding=auto, bookmarksnumbered=true, linktoc=all, pdfauthor={hzguide.cls}}

% font
\bool_if:NT \g_Noto_bool
{
    \setmainfont{Noto~Serif}[BoldFont={*~SemiBold}]
    \setsansfont{Noto~Sans}[BoldFont={*~SemiBold}]
}

\bool_if:NT \g_minted_bool
{
    \RequirePackage{minted}
    \setminted{
        encoding=UTF8,
        fontsize=\small,
        tabsize=2,
        breaklines=true,
        breakafter=\\/,
        linenos=false,
        frame=none
    }
    \patchcmd{\FV@ListVSpace}{\@topsepadd\topsep}{\vspace{.25\onelineskip}}{}{}
}

\bool_if:NT \g_pairquote_bool
{
    \RequirePackage{csquotes}
    \MakeOuterQuote{"}
}

\LoadPackageSet

\bool_if:NT \g_template_bool
{
    \input{hztemplate.tex}
}

\ifLang{chinese}
{
    \bool_gset_true:N \g_CJK_bool
    \newcommand\prenum{第}
}

\ifLang{japanese}
{
    \bool_gset_true:N \g_CJK_bool
    \newcommand\prenum{第}
}

\ifLang{korean}{
    \IfLuatex{
        \RequirePackage[hangul]{luatexko}
    }[
        \RequirePackage[hangul]{xetexko}
    ]

    \bool_if:NT \g_Noto_bool
    {
        \setmainhangulfont{Noto~Serif~KR}[BoldFont={*~SemiBold}, Script=Hangul, Language=Korean]
        \setsanshangulfont{Noto~Sans~KR}[BoldFont={*~Medium}, Script=Hangul, Language=Korean]
    }
    \bool_gset_true:N \g_CJK_bool
    \newcommand\prenum{제}
	\renewcommand*{\printpartname}{\partnamefont\prenum}
	\renewcommand*{\printpartnum}{\partnumfont\thepart\space\partnamefont\partname}
	\renewcommand*{\partnamenum}{\space}
    \xspaceaddexceptions{\이 \가 \을 \를 \와 \과 \로 \으로 \으 \은 \는 \라 \이라}
}

\ExplSyntaxOff

% settings per language

\ifLang{chinese}
{
    \RequirePackage{xeCJK}
    \setCJKmainfont{Noto Serif SC}
    \setCJKsansfont{Noto Sans SC}
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
            danger=危险,
            warning=警告,
            caution=注意事项,
            notice=注意,
            note=注
        }
    \LineImageSetup{raise=0pt}
    }
}

\ifLang{TC}
{
    \RequirePackage{xeCJK}
    \setCJKmainfont{Noto Serif TC}
    \setCJKsansfont{Noto Sans TC}
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
            danger=危險,
            warning=警告,
            caution=小心,
            notice=注意,
            note=注
        }
    \LineImageSetup{raise=0pt}
    }
}

\ifLang{czech}
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

\ifLang{danish}
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

\ifLang{dutch}
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

\ifLang{finnish}
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

\ifLang{french}
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

\ifLang{german}
{
    \RequirePackage{polyglossia}
    \setmainlanguage[variant=german, spelling=new, latesthyphen=true]{german}
    \setotherlanguage{english}
    \AtBeginDocument{
        \AdmonitionSetup {
            danger=GEFAHR,
            warning=WARNUNG,
            caution=VORSICHT,
            notice=HINWEIS,
            note=ANMERKUNG
        }
    }
}

\ifLang{italian}
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

\ifLang{japanese}
{
	\RequirePackage{luatexja}             % \RequirePackage{xeCJK} 
	\RequirePackage{luatexja-fontspec}    % \setCJKmainfont{Noto Serif JP}
    \setmainjfont{Noto Serif JP}          % \setCJKsansfont{Noto Sans JP}
    \setsansjfont{Noto Sans JP}           % \punctstyle{fullwidth}
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

\ifLang{korean}
{
    \AtBeginDocument{
        \renewcommand*{\contentsname}{차례}
        \AdmonitionSetup {
            danger=위험,
            warning=경고,
            caution=주의,
            notice=주의, % 알림
            note=참고
        }
    }
}

\ifLang{norwegian}
{
    \RequirePackage{polyglossia}
    \setmainlanguage{norwegian}
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

\ifLang{polish}
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

\ifLang{portuguese} % Brazilian
{
    \RequirePackage{polyglossia}
    \setmainlanguage{portuguese}
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

\ifLang{russian}
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

\ifLang{slovak}
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

\ifLang{spanish} % Latin
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

\ifLang{swedish}
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
            note=ANMÄRKNING % note=OBSERVERA
        }
    }
}

\ifLang{turkish}
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

% # document structure _____________________________________________________________

% ## layout

\tl_new:N \g_layout_type
\dim_zero_new:N \vartwosecindent

\bool_new:N \g_column_vartwo_bool

\NewDocumentCommand \IfVartwo { m O{} }
{
    \bool_if:NTF \g_column_vartwo_bool { #1 }{ #2 }
}

\NewDocumentEnvironment {IfVartwoEnlarge} { O{-\vartwosecindent} +b }
{
    \bool_if:NTF \g_column_vartwo_bool
    {
        \begin{adjustwidth}{#1}{0pt}
        #2
        \end{adjustwidth}
    }{
        #2
    }
}{}

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
        {JB5}          { \layout_paper_jbv: } % JIS B5 = 사륙배판
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


% JB5
\cs_new:Nn \layout_paper_jbv:
{
    \dim_gset:Nn \stockwidth {210mm}
    \dim_gset:Nn \stockheight {297mm}
    \dim_gset:Nn \paperwidth {182mm}
    \dim_gset:Nn \paperheight {257mm}
	\dim_gset:Nn \ulmargin {28.5mm} % textheight: 257 - 57 = 200 mm
    \dim_gset:Nn \lrmargin {26mm} % textwidth: 130 mm (= 182 - 52)
    \dim_gset:Nn \vartwomargin {14mm}
}

% slide
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

% column

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
        \AddToHook{shipout/background}[./trimmarks]{\ifshowtrims\put(0,0){\trimmarks}\fi}
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
        { slide }     { \layout_settle_slide: }
        { arbitrary } { \layout_settle_arbitrary: }
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
    \object_align:n {\raggedright}
}

\cs_new:Nn \layout_settle_vartwo:
{
    \layout_column_vartwo:
    \folio_vartwo:
    \object_align:n {\raggedright}
}

\cs_new:Nn \layout_settle_slide:
{
    \layout_slide:
    \pagestyle{empty}
    \copypagestyle{chapter}{plain}
    \object_align:n {\centering}
}

\cs_new:Nn \layout_settle_arbitrary:
{
    \layout_arbitrary:
    \tl_set:Nn \hffont {\footnotesize}
    \makeevenfoot{plain}{}{\hffont\thepage}{}
    \makeoddfoot{plain}{}{\hffont\thepage}{}
    \pagestyle{plain}
    \copypagestyle{chapter}{plain}
    \object_align:n {\centering}
}

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
    \IfBooleanF{#1}
    {
        \layout_settle:
    }
    \bool_if:NT \g_layout_showlayout_bool
    {
        \AtBeginDocument{ \ShowPageLayout }
    }
}

\LayoutSetup*{paper=A4, column=one}

% ## pagestyle

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
    markdelimiter   .tl_gset:N =     \g_ps_markdelimiter_tl,
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

\keys_set:nn { pagestyle } { markdelimiter=\quad }
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
    \bool_if:NF \g_ps_chapterpage_bool
    {
        \makeheadrule{chapter}{0pt}{0pt}
        \makeevenhead{chapter}{}{}{}
        \makeoddhead{chapter}{}{}{}
    }
    \bool_if:NTF \g_ps_chaptermark_bool
    {        
        \int_compare:nTF { \c@secnumdepth >= 0 }
        {
            \renewcommand\chaptermark[1]{
                \if@mainmatter
                    \markboth{\thechapter\g_ps_markdelimiter_tl##1}{\thechapter\g_ps_markdelimiter_tl##1}
                \else
                    \markboth{##1}{##1}
                \fi
            }
        }{
            \renewcommand\chaptermark[1]{\markboth{##1}{##1}}
        }
    }{
        \renewcommand\chaptermark[1]{}
    }
    \bool_if:NTF \g_ps_sectionmark_bool
    {
        \int_compare:nTF { \c@secnumdepth >= 1 }
        {
            \renewcommand\sectionmark[1]{\markright{\thesection\g_ps_markdelimiter_tl##1}}
        }{
            \renewcommand\sectionmark[1]{\markright{##1}}
        }
    }{
        \renewcommand\sectionmark[1]{}
    }
}

% ## chapter, section, paragraph

\NewDocumentCommand \chapterline {}
{
    \chapteralign
    \chapterfont
    \color{\chaptercolor}
}

\cs_new:Npn \style_chapter_configure:n #1
{
    \chapterstyle{#1}
    \renewcommand{\chapnamefont}{\chapterline\chapternamesize}
    \renewcommand{\chapnumfont}{\chapterline\chapternumbersize}
    \renewcommand{\chaptitlefont}{\chapterline\chaptertitlesize}
}

\cs_new:Nn \style_chapter_cjk:
{
    \renewcommand{\printchaptername}{\CJKchapterstyle}
    \renewcommand{\printchapternum}{\CJKchapterstyle*}
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
    \nopagebreak
}

\NewDocumentCommand \SectionMultilineRule { m }
{
    \SectionMultiline
    {
        #1
        \nopagebreak\vskip-1\onelineskip
        \IfVartwo{

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
}

\newcommand*\secstyle{ \sectionline\secfontsize }
\newcommand*\subsecstyle{ \sectionline\subsecfontsize }
\newcommand*\subsubsecstyle{ \sectionline\subsubsecfontsize }
\setsecheadstyle{ \secstyle }
\setsubsecheadstyle{ \subsecstyle }
\setsubsubsecheadstyle{ \subsubsecstyle }

\cs_new:Nn \style_article:
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
}

\cs_new:Nn \style_cft_section:
{
    \renewcommand\@tocmaketitle{
        \section*{\contentsname}
        \markboth{\contentsname}{\contentsname}
        % \markright{\contentsname}
    }
    \renewcommand\@lofmaketitle{
        \section*{\listfigurename}
        \markboth{\listfigurename}{\listfigurename}
        % \markright{\listfigurename}
    }
    \renewcommand\@lotmaketitle{
        \section*{\listtablename}
        \markboth{\listtablename}{\listtablename}
        % \markright{\listtablename}
    }
}

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
    \setlist{partopsep=0pt, topsep=0.5\onelineskip, itemsep=0pt}
    \setlist[itemize]{labelindent=1em,labelwidth=0.5em,labelsep=0.5em, leftmargin=*}
    \setlist[enumerate]{labelindent=1em,labelwidth=1.25em,labelsep=0.5em, leftmargin=*}
}

\cs_new:Nn \style_paragraph_indent:
{
    \skip_set:Nn \hzparskip {0pt}
    \abnormalparskip{\hzparskip}
    \SetTextStyle{\setlength\parindent{\hzparindent}}

    \ObjectSetup{
        beforeskip=.75\onelineskip,
        afterskip=.75\onelineskip
    }
}

\cs_new:Nn \style_paragraph_interval:
{
    \abnormalparskip{\hzparskip}
    \setlength{\parindent}{0em}
    \SetTextStyle{\abnormalparskip{\hzparskip}}
    \ObjectSetup{
        beforeskip=.5\onelineskip,
        afterskip=.5\onelineskip
    }
}

\bool_new:N \g_section_multiline_bool

\keys_define:nn { HzHeading }
{
    linespacing           .code:n = { \setSpacing {#1} },
    article               .bool_set:N = \g_style_article_bool,
    cftsection            .bool_set:N = \g_style_cft_section_bool,
    chapterwider          .bool_set:N = \g_style_chapterwider_bool,
    chapterstyle          .code:n = { \style_chapter_configure:n {#1} },
    cjkchapter            .bool_set:N = \g_style_chapter_cjk_bool,
    nochaptername         .bool_set:N = \g_style_nochaptername_bool,
    chapteralign          .tl_set:N = \chapteralign,
    chapterfont           .tl_set:N = \chapterfont,
    chaptercolor          .tl_set:N = \chaptercolor,
    chapternamesize       .tl_set:N = \chapternamesize,
    chapternumbersize     .tl_set:N = \chapternumbersize,
    chaptertitlesize      .tl_set:N = \chaptertitlesize,
    chaptercontents       .bool_set:N = \g_chapter_contents_bool,
    sectionstyle          .code:n = { \style_section_configure:n {#1} },
    sectionalign          .tl_set:N = \sectionalign,
    sectionfont           .tl_set:N = \sectionfont,
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
    \bool_if:NT \g_style_chapter_cjk_bool
    {
        \style_chapter_cjk:
    }
    \bool_if:NT \g_style_nochaptername_bool
    {
        \def\@chapapp{}
        \def\prenum{}
    }
    \bool_if:NT \g_column_vartwo_bool
    {
        \tl_set:Nn \chapteralign {\raggedleft}
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
    \bool_if:NT \g_style_article_bool
    {
        \style_article:
        \style_cft_section:
    }
    \bool_if:NT \g_style_cft_section_bool
    {
        \style_cft_section:
    }

    \bool_if:NT \g_chapter_contents_bool
    {
        \ChapterContentsEnable
    }
}

\HeadingSetup{
    linespacing=1.25,
    chapterfont=\normalfont\bfseries,
    chaptercolor=black,
    chapternamesize=\huge,
    chapternumbersize=\HUGE,
    chaptertitlesize=\Huge,
    sectionalign=\raggedright, %\memRTLraggedright,
    sectionfont=\normalfont\bfseries,
    sectionsize=\Large,
    subsectionsize=\large,
    subsubsectionsize=\normalsize,
    parskip=.25\onelineskip,
    parindent=1em
}

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

\makechapterstyle{tight}{
    \chapterstyle{default}
    \setlength{\beforechapskip}{3\onelineskip}
    \setlength{\midchapskip}{.5\onelineskip}
    \setlength{\afterchapskip}{2\onelineskip}
}

\makechapterstyle{sparse}{
    \chapterstyle{default}
    \setlength{\beforechapskip}{5\onelineskip}
    \setlength{\midchapskip}{\onelineskip}
    \setlength{\afterchapskip}{4\onelineskip}
}

\NewDocumentCommand \TableOfContents { s o }
{
    \group_begin:
    \IfValueT { #2 }{ \setSpacing{#2} }
    \IfBooleanTF {#1}
    {
        \tableofcontents
    }{
        \pdfbookmark[0]{\contentsname}{Contents}
        \tableofcontents*
    }
    \group_end:
}

\NewDocumentCommand \ListOfFigures{ s o }
{
    \group_begin:
    \IfValueT { #2 }{ \setSpacing{#2} }
    \IfBooleanTF {#1}
    {
        \listoffigures
    }{
        \pdfbookmark[0]{\listfigurename}{Figures}
        \listoffigures*
    }
    \group_end:
}

% ## chpater contents

%\ChapterContentsEnable(chapter)[section depth]
\NewDocumentCommand \ChapterContentsEnable { d() O{2} }
{
    \newcounter{tocmarker}
    \renewcommand\mempreaddchaptertotochook{ \cftinserthook{toc}{end-\thetocmarker} }
    \renewcommand\mempostaddchaptertotochook{ \stepcounter{tocmarker} \cftinserthook{toc}{start-\thetocmarker} }
    \let\normalchangetocdepth\changetocdepth
    \IfValueTF {#1}
    {
        \renewcommand\memendofchapterhook{
            \int_compare:nTF { \value{chapter} = #1 }
            {
                \ChapterContents{#2}
            }{}
        }
    }{
        \renewcommand\memendofchapterhook{
            \ChapterContents{#2}
        }
    }
}

\NewDocumentCommand \ChapterContents { m }
{
    \begingroup
        \setcounter{@memmarkcntra}{\value{tocdepth}}
        \let\changetocdepth\@gobble
        \normalchangetocdepth{-10}
        \cftinsertcode{start-\thetocmarker}{\normalchangetocdepth{#1}}
        \cftinsertcode{end-\thetocmarker}{\normalchangetocdepth{-10}}
        \let\printtoctitle\@gobble
        \renewcommand\@tocmaketitle{}
        \tableofcontents*\bigskip
    \endgroup
    \setcounter{tocdepth}{\value{@memmarkcntra}}
}

\NewDocumentCommand \ChapterContentsDisable {}
{
    \renewcommand\memendofchapterhook{
        \cftinsertcode{start-\thetocmarker}{}
        \cftinsertcode{end-\thetocmarker}{}
    }
}

% ## page breaking before sections

\newcounter{unsec}[chapter] % in case that \setsecnumdepth{chapter} is declared
\newcounter{unsubsec}[unsec]

\tl_new:N \g_tex_text_style
\NewDocumentCommand \SetTextStyle { m o }
{
    \tl_gset:Nn \g_tex_text_style {#1}
    \IfValueT { #2 }
    {
        #2
        \renewcommand{\@makefntext}[1]{\makefootmark#2 ##1}
    }
    \AtBeginDocument{#1}
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

% ## action

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

% ## watermark

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

% \watermark{x=30,y=30,fontsize=90,color=red,text={...},image=foo,rotate=50}
\NewDocumentCommand \watermark { m }
{
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
    \bool_if:NT \g_thumbindex_active_bool
    {
        \int_decr:N \l_thumbindex_int
        \thumbindex
    }
}

% ## thumb index

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
    vertical  .bool_set:N = \l_thumbindex_vertical_bool
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

    \bool_if:NTF \l_thumbindex_vertical_bool
    {
        \tl_set:Nn \l_thumbindex_label
        {
            \int_if_odd:nT {\value{page}}
            {
                \rotatebox{-90}{
                    \colorbox{\l_thumbindex_bgcolor}{
                        \parbox[c][\l_thumbindex_height]{\l_thumbindex_width}{
                            \color{\l_thumbindex_fgcolor}
                            \l_thumbindex_style \l_thumbindex_content
                        }
                    }
                }
            }
        }
    }{
        \tl_set:Nn \l_thumbindex_label
        {
            \int_if_odd:nT {\value{page}}
            {
                \colorbox{\l_thumbindex_bgcolor}{
                    \parbox[c][\l_thumbindex_height]{\l_thumbindex_width}{
                        \color{\l_thumbindex_fgcolor}
                        \l_thumbindex_style \l_thumbindex_content
                    }
                }
            }
        }
    }
}

\NewDocumentCommand \thumbindex {}
{
    \int_set:Nn \l_thumbindex_y { \l_thumbindex_origin - (\l_thumbindex_height_int + \l_thumbindex_interval) * \l_thumbindex_int }
    \int_compare:nTF { \l_thumbindex_y < \l_thumbindex_boffset } {
        \int_set:Nn \l_thumbindex_y { \l_thumbindex_origin }
        \int_zero:N \l_thumbindex_int
    }{
        \int_incr:N \l_thumbindex_int
    }

    \AddToShipoutPictureBG
    {
        \dim_set:Nn \unitlength {1mm}
        \put(\l_thumbindex_x, \l_thumbindex_y)
        {
            \l_thumbindex_label
        }
    }
}

\bool_new:N \g_thumbindex_active_bool
\NewDocumentCommand \ThumbIndexEnable {}
{
    \bool_if:NTF \g_ps_chaptermark_bool
    {
        \renewcommand\chaptermark[1]{\markboth{##1}{##1}\thumbindex}
    }{
        \renewcommand\chaptermark[1]{\thumbindex}
    }
    \bool_gset_true:N \g_thumbindex_active_bool
}

\NewDocumentCommand \ThumbIndexDisable {}
{
    \ClearShipoutPictureBG
    \bool_if:NTF \g_ps_chaptermark_bool
    {
        \renewcommand\chaptermark[1]{\markboth{##1}{##1}}
    }{
        \renewcommand\chaptermark[1]{}
    }
    \bool_gset_false:N \g_thumbindex_active_bool
}

% # images and tables _________________________________________________________

\graphicspath{ {images/}{../images/} }

\NewDocumentCommand \ShowGraphicspath { O{\scriptsize} }
{
    \group_begin:
        #1 \tl_to_str:N \Ginput@path
    \group_end:
}

% ## caption

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
}

\CaptionSetup{
    beforeskip = 1ex,
    afterskip = 1ex,
    align = \raggedright,
	align-short = \raggedright,
    font = \rmfamily\bfseries\small,
    delimiter=:\space
}

% measuring boxes
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

\dim_zero_new:N \g_protrude_dim
\box_new:N \l_image_box
\box_new:N \l_text_box

% ## \image*|[options]{image}[extra image](caption)<short caption>

\keys_define:nn { image }
{
    beforeskip    	.skip_set:N = \l_image_before_skip,
    afterskip     	.skip_set:N = \l_image_after_skip,
    gap     	    .skip_set:N = \l_image_gap_skip,
    align         	.tl_set:N 	= \l_image_align,
    float         	.bool_set:N = \l_image_float_bool,
	float-placement	.tl_set:N	= \l_image_float_placement_tl,
    frame         	.bool_set:N = \l_image_frame_bool,
    fitline       	.bool_set:N = \l_image_fitline_bool, % fit images to the specified width; not valid when an extra image is given.
    fitwidth      	.tl_set:N 	= \l_image_fitwidth_tl,
    flush         	.bool_set:N = \l_image_flush_bool, % flush images into the left margin
    scale         	.tl_set:N 	= \l_image_scale_tl,
    landscape     	.bool_set:N = \l_image_landscape_bool,
    clockwise     	.bool_set:N = \l_image_clockwise_bool,
	middle			.bool_set:N = \l_image_vertical_middle_bool,
    caption       	.tl_set:N 	= \l_image_caption_tl,
	caption-short  	.tl_set:N 	= \l_image_caption_short_tl,
	caption-verb	.bool_set:N = \l_image_caption_verbatim_bool,
	caption-ignore	.bool_set:N = \l_image_caption_ignore_bool,
	caption-fit		.bool_set:N = \l_image_caption_fit_bool, % fit the caption to the image width
    label         	.tl_set:N 	= \l_image_label_tl,
    legend        	.bool_set:N = \l_image_legend_bool,
    showfilename  	.bool_set:N = \l_image_showfilename_bool,
    star          	.tl_set:N 	= \l_image_star_tl,
    vbar          	.tl_set:N 	= \l_image_vbar_tl,
    fake            .bool_set:N = \l_image_fake_bool
}
\bool_new:N \l_image_extra_bool

\NewDocumentCommand \ImageSetup { m }
{
    \keys_set:nn { image } {#1}
	\exp_args:NNx \def\fps@figure { \l_image_float_placement_tl }
}

\ImageSetup{
    beforeskip=\hznulldim,
    afterskip=\hznulldim,
    gap=1em,
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
    \bool_if:NTF \l_image_fake_bool 
    {
        \image_save_fake:nn { #4 }{ #5 }
    }{
        \exp_args:Nxx \image_save:nn { #4 }{ #5 }
    }
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

\cs_new:Npn \image_save_fake:nn #1 #2
{
    \bool_if:NTF \l_image_extra_bool
    {
        \hbox_set:Nn \l_image_box
        {
            \parbox{.49\linewidth}{ \fakeimage[#1] }\space
            \parbox{.49\linewidth}{ \fakeimage[#2] }
        }
    }{
        \hbox_set:Nn \l_image_box { \fakeimage[#1] }
    }
}

\NewDocumentCommand\fakeimage{ O{IMAGE} }
{
    \begin{FrameBox}\centering
    \mbox{}\vspace{2\onelineskip}\\
    \tl_to_str:n { #1 } \\
    \vspace{2.5\onelineskip}
    \end{FrameBox}
}

\cs_new:Npn \image_save:nn #1 #2
{
    \bool_if:NTF \l_image_frame_bool
    {
        \bool_if:NTF \l_image_extra_bool {
            \hbox_set:Nn \l_image_box
            {
                \objectframe{
                    \includegraphics[scale=\l_image_scale_tl]{#1}
                    \hspace{\l_image_gap_skip}
                    \includegraphics[scale=\l_image_scale_tl]{#2}
                }
            }
        }{
            \hbox_set:Nn \l_image_box
            {
                \objectframe{ \includegraphics[scale=\l_image_scale_tl]{#1} }
            }
            \bool_if:NT \l_image_fitline_bool
            {
                \dim_set_towidth:Nn \l_tmpa_dim
                {
                    \box_use:N \l_image_box
                }
                \dim_compare:nT { \l_tmpa_dim > \l_image_fitwidth_tl }
                {
                    \hbox_set:Nn \l_image_box
                    {
                        \objectframe{ \includegraphics[width=\l_image_fitwidth_tl]{#1} }
                    }
                }
            }
        }
     }{
         \bool_if:NTF \l_image_extra_bool {
            \hbox_set:Nn \l_image_box{
                    \includegraphics[scale=\l_image_scale_tl]{#1}
                    \hspace{\l_image_gap_skip}
                    \includegraphics[scale=\l_image_scale_tl]{#2}
            }
        }{
            \hbox_set:Nn \l_image_box
            {
                \includegraphics[scale=\l_image_scale_tl]{#1}
            }
            \bool_if:NT \l_image_fitline_bool
            {
                \dim_set_towidth:Nn \l_tmpa_dim
                {
                    \box_use:N \l_image_box
                }
                \dim_compare:nT { \l_tmpa_dim > \l_image_fitwidth_tl }
                {
                    \hbox_set:Nn \l_image_box
                    {
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
    \dim_set_towidth:Nn \l_tmpb_dim { \box_use:N \l_image_box }
    \dim_compare:nT { \g_protrude_dim > 0pt }
    {
        \dim_set_toheight:Nn \l_tmpa_dim { \box_use:N \l_image_box }
        \object_locate:N \l_tmpa_dim
    }
    \bool_if:NTF \l_image_clockwise_bool
    {
        \rotatebox{-90}{
            \begin{minipage}{\textwidth}
                \l_image_align\mbox{}
                \box_use:N \l_image_box
                \image_caption:
            \end{minipage}
        }
        \vspace{\l_tmpb_dim}
    }{
        \raisebox{ -\l_tmpb_dim }{
            \rotatebox{90}{
                \begin{minipage}{\textwidth}
                    \l_image_align\mbox{}
                    \box_use:N \l_image_box
                    \image_caption:
                \end{minipage}
            }
        }
    }
}

\cs_new:Nn \image_caption:
{
	\bool_if:NT \l_image_caption_fit_bool
	{
		\dim_set_towidth:Nn \l_tmpa_dim { \box_use:N \l_image_box }
		\captionwidth{\l_tmpa_dim}
		\changecaptionwidth
	}
    \bool_if:NT \l_image_showfilename_bool
    {
        \bool_if:NTF \g_image_counter_bool
        {
            \int_gincr:N \g_image_counter_int
            \legend{ \int_use:N \g_image_counter_int }
        }{
            \legend{\exp_args:Nx \tl_to_str:N \l_image_label_tl }
        }
    }

    \tl_if_empty:NF \l_image_caption_tl
	{
		\bool_if:NF \l_image_caption_ignore_bool
		{
            \bool_if:NT \l_image_caption_verbatim_bool
            {
                % \tl_set:Nx \l_image_caption_tl { \tl_to_str:N \l_image_caption_tl }
                \regex_replace_all:nnN { ([\\\`\~\#\$\^\&\_]) } { \c{\1} } \l_image_caption_tl 
            }
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

\NewDocumentCommand \listimg { s O{.25\onelineskip} m }
{
    \par\vspace{#2}
    \IfBooleanTF{#1}
    {
        \fakeimage[#3]
    }{
        \includegraphics[scale=\l_image_scale_tl]{#3}
        \bool_if:NT { \l_image_showfilename_bool }
        {
            \bool_if:NT \g_image_counter_bool
            {
                \int_gincr:N \g_image_counter_int
                \legend{ \int_use:N \g_image_counter_int }
            }{
                \tl_set:Nx \l_tmpa_tl { #3 }
                \group_begin:
                \allowbreak \color{ImageName} \scriptsize \tl_to_str:N \l_tmpa_tl
                \group_end:
            }
        }
    }
}

\keys_define:nn { mate }
{
    mate        .tl_set:N = \g_mate_tl,
    firstpath   .tl_set:N = \g_mate_first_path_tl,
    secondpath  .tl_set:N = \g_mate_second_path_tl
}
\NewDocumentCommand \MateSetup { m }
{
    \keys_set:nn { mate }{ #1 }
}

\MateSetup{
    mate = first/second/both,
    firstpath = ../images/kor/,
    secondpath = ../images/eng/
}

\NewDocumentCommand \mateimage { O{} m }
{
    \str_case:Vn \g_mate_tl
    {
        { first }{ 
            \image[#1]{\g_mate_first_path_tl #2}
        }
        { second }{ 
            \image[#1]{\g_mate_second_path_tl #2}
        }
        { both }{ 
            \image[#1]{\g_mate_first_path_tl #2}
            \par
            \image[#1]{\g_mate_second_path_tl #2}
        }
    }
}

% ## \illustimage*^[ options ]{ image filename }( caption ){ description }
%\illustimage*: user-specified action
%\illustimage^: the option of "extra" is enabled.

\dim_new:N \l_illustimage_image_width_dim
\dim_new:N \l_illustimage_text_width_dim

\bool_new:N \in_illustimage_bool
\bool_new:N \l_illustimage_extra_bool
\keys_define:nn { illustimage }
{
    beforeskip      .skip_set:N = \l_illustimage_before_skip,
    extraskip       .skip_set:N = \l_illustimage_extra_skip,
    afterskip       .skip_set:N = \l_illustimage_after_skip,
    frame           .bool_set:N = \l_illustimage_frame_bool,
    gap             .dim_set:N = \l_illustimage_gap_dim,
    scale           .tl_set:N = \l_illustimage_scale_tl,
    position        .tl_set:N = \l_illustimage_position_tl,
    voffset         .skip_set:N = \l_illustimage_voffset_skip,
    valign          .tl_set:N = \l_illustimage_valign_tl,
    caption         .tl_set:N = \l_illustimage_caption_tl,
	caption-verb	.bool_set:N = \l_illustimage_caption_verbatim_bool,
	caption-ignore	.bool_set:N = \l_illustimage_caption_ignore_bool,
	caption-align	.tl_set:N = \l_illustimage_caption_align_tl,
    label           .tl_set:N = \l_illustimage_label_tl,
    legend          .bool_set:N = \l_illustimage_legend_bool,
    minwidth       .dim_set:N = \l_illustimage_minimum_width_dim,
	imagealign		.tl_set:N = \l_illustimage_image_align_tl, % this is effective when minwidth is specified
    broad           .bool_set:N = \l_illustimage_broad_bool, % take the full width in case of vartwo
    showfilename    .bool_set:N = \l_illustimage_showfilename_bool,
    textstyle       .tl_set:N = \l_illustimage_textstyle_tl,
    star            .tl_set:N = \l_illustimage_star_tl,
    enum            .tl_set:N = \l_illustimage_enum_tl,
    fake            .bool_set:N = \l_illustimage_fake_bool
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
    beforeskip=.25\onelineskip,
    extraskip=.5\onelineskip,
    afterskip=.25\onelineskip,
    frame=false,
    minwidth=0pt,
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
		\bool_set_true:N \l_illustimage_extra_bool
	}
    \IllustImageSetup{#3}
    \bool_if:NT \l_illustimage_broad_bool
    {
        \bool_if:NT \g_column_vartwo_bool
        {
			\begin{adjustwidth}{-\vartwosecindent}{0pt}
		}
    }
	% \tl_use:N \l_illustimage_hook_tl
    \IfValueT{#5}
    {
        \tl_set:Nn \l_illustimage_caption_tl {#5}
    }
    % save image & text
    \tl_if_empty:NT \l_illustimage_label_tl
    {
        \tl_set:Nn \l_illustimage_label_tl {#4}
    }
    \bool_if:NTF \l_illustimage_fake_bool
    {
        \hbox_set:Nn \l_image_box { \parbox{.4\linewidth}{ \fakeimage[#4] }}
    }{
        \bool_if:NTF \l_illustimage_frame_bool
        {
            \hbox_set:Nn \l_image_box
                { \objectframe{\includegraphics[scale=\l_illustimage_scale_tl]{#4}} }
        }{
            \hbox_set:Nn \l_image_box
                { \includegraphics[scale=\l_illustimage_scale_tl]{#4} }
        }
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
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_text_width_dim}
            \g_tex_text_style\l_illustimage_textstyle_tl\noindent #6
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
    \bool_if:NTF \l_illustimage_extra_bool
    {
        \object_skip_before:n {\l_illustimage_extra_skip}
    }{
        \object_skip_before:n {\l_illustimage_before_skip}
    }
    \begin{minipage}{\linewidth}
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_image_width_dim}
            \vspace{0pt}
			\l_illustimage_image_align_tl
            \mbox{} \box_use:N \l_image_box
            \illustimage_caption:
        \end{minipage}
        \hfill
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_text_width_dim}
            \vspace{0pt}
            \vspace{\l_illustimage_voffset_skip}
            \box_use:N \l_text_box
        \end{minipage}
    \end{minipage}
    \object_skip_after:n {\l_illustimage_after_skip}
}

\cs_new:Nn \illustimage_put_right:
{
    \bool_if:NTF \l_illustimage_extra_bool
    {
        \object_skip_before:n {\l_illustimage_extra_skip}
    }{
        \object_skip_before:n {\l_illustimage_before_skip}
    }
    \begin{minipage}{\linewidth}
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_text_width_dim}
            \vspace{0pt}
            \vspace{\l_illustimage_voffset_skip}
            \box_use:N \l_text_box
        \end{minipage}
        \hfill
        \begin{minipage}[\l_illustimage_valign_tl]{\l_illustimage_image_width_dim}
            \vspace{0pt}
			\l_illustimage_image_align_tl
            \mbox{} \box_use:N \l_image_box
            \illustimage_caption:
        \end{minipage}
    \end{minipage}
    \object_skip_after:n {\l_illustimage_after_skip}
}

\cs_new:Nn \illustimage_caption:
{
    \bool_if:NT \l_illustimage_showfilename_bool
    {
        \bool_if:NTF \g_image_counter_bool
        {
            \int_gincr:N \g_image_counter_int
            \legend{ \int_use:N \g_image_counter_int }
        }{
            \legend{\exp_args:No \tl_to_str:N \l_illustimage_label_tl }
        }
    }
    \tl_if_empty:NF \l_illustimage_caption_tl
    {
		\captionstyle{\l_illustimage_caption_align_tl}
		\bool_if:NF \l_illustimage_caption_ignore_bool
		{
            \bool_if:NTF \l_illustimage_caption_verbatim_bool
            {
                \tl_set:Nx \l_illustimage_caption_tl { \tl_to_str:N \l_illustimage_caption_tl }
            }{
                \regex_replace_all:nnN { \_ } { \c{_} } \l_illustimage_caption_tl
            }
			\bool_if:NTF \l_illustimage_legend_bool
            {
				\legend{\l_illustimage_caption_tl}
			}{
				\imgcaption{\l_illustimage_caption_tl}
				\label{\l_illustimage_label_tl}
			}
		}
    }
}

\NewDocumentEnvironment {IllustImage} { s t^ O{} m d() +b }
{
    \IfBooleanT {#1} {
        \exp_args:No \IllustImageSetup{ \l_illustimage_star_tl }
    }
    \IfBooleanT {#2}
    {
        \bool_set_true:N \l_illustimage_extra_bool
    }
    \IllustImageSetup{#3}
    \IfValueT {#5}
    {
        \tl_set:Nn \l_illustimage_caption_tl {#5}
    }
    \illustimage{#4}{#6}
}{}

% \begin{IllustEnum}[options]{image_file}
% \begin{IllustEnum}*    : restart the order number
% \begin{IllustEnum}^    : apply ad-hoc options, specified to the option of "star" of \illustimage*)

\NewDocumentEnvironment { IllustEnum } { s t^ o m d() +b }
{
    \exp_args:No \IllustImageSetup{ \l_illustimage_enum_tl }
    \IfBooleanT {#1}
	{
        \bool_set_true:N \l_illustimage_extra_bool
    }
    \IfBooleanT {#2}
	{
        \exp_args:No \IllustImageSetup{ \l_illustimage_star_tl }
    }
    \IfValueT {#3}
	{
        \IllustImageSetup{#3}
    }
    \IfValueT {#5}
    {
        \tl_set:Nn \l_illustimage_caption_tl {#5}
    }
    \IfBooleanTF{#1}
    {
        \illustimage{#4}{
            \begin{enumerate}[series=IlluEnum, leftmargin=1.5em]
                #6
            \end{enumerate}
        }
    }{
        \illustimage{#4}{
            \begin{enumerate}[series=IlluEnum, resume=IlluEnum, leftmargin=1.5em]
                #6
            \end{enumerate}
        }
    }
}{}

% ## \img[raise]{foo}

\keys_define:nn { lineimg }
{
    scale           .tl_set:N = \l_lineimg_scale_tl,
    raise           .tl_set:N = \l_lineimg_raise_tl,
    showfilename    .bool_set:N  = \l_lineimg_showfilename_bool,
    before          .tl_set:N = \l_lineimg_before_tl,
    after           .tl_set:N = \l_lineimg_after_tl
}

\NewDocumentCommand \LineImageSetup { m }
{
    \keys_set:nn { lineimg } { #1 }
}

\LineImageSetup{
    scale=1,
    raise=-.25ex,
    showfilename=false,
    before=\space,
    after=\space
}

\NewDocumentCommand \img { s O { \l_lineimg_raise_tl } m }
{

    \l_lineimg_before_tl
    \IfBooleanTF{#1}{
        \fakeimg[#3]
    }{
        \raisebox{#2}{
            \includegraphics[scale=\l_lineimg_scale_tl]{#3}
        }
        \bool_if:NT { \l_lineimg_showfilename_bool}
        {
            \group_begin:
            \allowbreak \color{ImageName} \scriptsize \tl_to_str:n { #3 }
            \group_end:
        }
    }
    \l_lineimg_after_tl
}

\NewDocumentCommand\fakeimg{ o }
{
    \colorbox{darkgray}{
        \bfseries
        \raisebox{.75em}{ \rotatebox{180}{\textcolor{white}{?}} }
        \IfValueTF{ #1 }
        {
            \textcolor{white}{ \tl_to_str:n {#1}? }
        }{
            \textcolor{white}{?}
        }
    }
}

%  ## callout
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
    tabs        .tl_set:N = \l_callout_tabs_tl
}

\NewDocumentCommand \CalloutSetup {m}
{
    \keys_set:nn { callout } {#1}
}

\CalloutSetup{
    beforeskip=\hznulldim,
    afterskip=\hznulldim,
    column=3,
    font=\small,
    label={\makebox[1.25em]{\hfill\calloutno)}\enspace},
    tab=true,
    space=0.25em
}

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
    \l_callout_font_tl
    \IfBooleanTF {#1}
    {
        \begin{calloutenum}
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
\setlist[calloutenum]{label=\arabic*), noitemsep}

\definecolor{ImageName}{named}{violet}

\NewDocumentCommand \ShowImageFilename { s }
{
    \ImageSetup{showfilename=true}
    \IllustImageSetup{showfilename=true}
    \IfBooleanT{#1} {
        \LineImageSetup{showfilename=true}
    }
    \CaptionSetup{font=\color{ImageName}\scriptsize}
}
\int_new:N \g_image_counter_int
\bool_new:N \g_image_counter_bool
\NewDocumentCommand \ShowImageCounter { s }
{
    \bool_set_true:N \g_image_counter_bool
    \ImageSetup{showfilename=true}
    \IllustImageSetup{showfilename=true}
    \IfBooleanT{#1} {
        \LineImageSetup{showfilename=true}
    }
    \CaptionSetup{font=\color{ImageName}\scriptsize}
}
\NewDocumentCommand \ResetImageCounter {}
{
    \int_zero:N \g_image_counter_int
}

% ## album

\newcommand*{\albumhook}{\par}
\NewDocumentCommand \MakeAlbum { s O{1} m }
{
    \int_zero:N \l_tmpa_int
    \ImageSetup{scale=#2, fitline=true}
    \IfBooleanTF{#1}
    {
        \ImageSetup{showfilename=false}
    }{
        \ImageSetup{showfilename=true}
        \CaptionSetup{align=\raggedright, font=\ttfamily\small}
    }
    \ior_open:Nn \g_tmpa_ior { #3 }
    \ior_map_inline:Nn \g_tmpa_ior
    {
        \tl_set:Nn \l_tmpa_tl { ##1 }
        \tl_trim_spaces:N \l_tmpa_tl
        % if hash(#) is in filename
        \regex_replace_all:nnN { \cP\# } { \cO\# } \l_tmpa_tl
        \tl_if_empty:NF { \l_tmpa_tl }
        {
            \int_incr:N \l_tmpa_int
            \pdfbookmark[1]{\tl_to_str:N \l_tmpa_tl}{\int_use:N \l_tmpa_int}
            \image{\l_tmpa_tl}\albumhook
        }
    }
    \ior_close:N \g_tmpa_ior
}

% ## table

\cs_new:Npn \table_footnotestyle:n #1
{
    \renewcommand*{\thefootnote}{ \use:c {#1} {footnote} }
    \renewcommand*{\thempfootnote}{ \use:c {#1} {mpfootnote} }
}

\keys_define:nn { table }
{
    beforeskip    	.skip_set:N = \l_table_before_skip,
    afterskip     	.skip_set:N = \l_table_after_skip,
    float         	.bool_set:N = \l_table_float_bool,
	float-placement	.tl_set:N	= \l_table_float_placement_tl,
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
	star		  	.tl_set:N 	= \l_table_star_tl,
	vbar		  	.tl_set:N 	= \l_table_vbar_tl,
	protrude		.dim_set:N  = \l_table_protrude_dim, % valid only at vartwo
    style           .tl_set:N   = \l_table_style_tl,
    fake            .bool_set:N = \l_table_fake_bool % to contain csv lists or others
}

\NewDocumentCommand \TableSetup { m }
{
    \keys_set:nn { table } { #1 }
	\exp_args:NNx \def\fps@table { \l_table_float_placement_tl }
}

\TableSetup{
    beforeskip=\hznulldim,
    afterskip=\hznulldim,
    float=false,
	float-placement=tbh,
    landscape=false,
    legend=false,
    font=\rmfamily,
    fontsize=\small,
    footnotestyle=arabic,
    stretch=1,
	protrude=0pt
}

% \placetable*|[options](caption)<footnote>{tabular}
\NewDocumentCommand \placetable { s t| O{} d() d<> +m }
{
    \group_begin:
    \tl_use:N \l_table_style_tl
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
    \dim_set_towidth:Nn \l_tmpb_dim { \box_use:N \l_text_box  }
    \dim_compare:nT { \g_protrude_dim > 0pt }
    {
        \dim_set_toheight:Nn \l_tmpa_dim { \box_use:N \l_text_box  }
        \object_locate:N \l_tmpa_dim
    }
    \rotatebox{90}{
        \begin{minipage}{\l_tmpb_dim}
            \table_caption:
			\l_table_align_tl
        	\mbox{ \box_use:N \l_text_box }
			\table_footnote:
        \end{minipage}}
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
        \vspace{-.5\onelineskip}\par
        \begin{minipage}{\linewidth}
            \setfootnoterule{0pt}{0pt}{0pt}
            \l_table_footnote
        \end{minipage}
    }
}

\NewDocumentEnvironment { Table } { s t| o d() d<> +b }
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
    \bool_if:nTF \l_table_fake_bool
    { 
        \faketable{ #6 }
    }{
        \placetable{ #6 }
    }
}{}

\NewDocumentCommand{ \faketable }{ m }
{
    \object_skip_before:n {\l_table_before_skip}
    \table_caption: 
    \skip_vertical:N \belowcaptionskip
    \begin{RuleBox}
        #1
    \end{RuleBox}
    \object_skip_after:n {\l_table_after_skip}
}

\NewDocumentEnvironment { SpecTable } { s O{lX} d() d<> +b }
{
    \IfValueT{#3} { \tl_set:Nn \l_table_caption_tl {#3} }
    \IfValueT{#4} { \tl_set:Nn \l_table_footnote {#4} }
    \IfBooleanTF{#1}
    {
        \placetable{
            \begin{tblr}{colspec={#2}, hline{1,2,Z}=0.4pt, row{even}=backgray, row{1}={font=\bfseries}}
            #5
            \end{tblr}
        }
    }{
        \placetable{
            \begin{tblr}{colspec={#2}, hline{1,Z}=0.4pt, row{even}=backgray}
            #5
            \end{tblr}
        }
    }
}{}

\NewDocumentEnvironment { ImageTable } { s d<> +b }
{
    \IfValueT{#2} { \tl_set:Nn \l_table_footnote {#2} }
    \IfBooleanTF{#1}
    {
        \placetable[stretch=1,font=\small]{
            \begin{tblr}{X[c]X[c]}
            #3
            \end{tblr}
        }
    }{
        \placetable[stretch=1,font=\small]{
            \begin{tblr}{X[c]X[c]X[c]}
            #3
            \end{tblr}
        }
    }
}{}

% # lists _________________________________________________________________________

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

% ## \NewTerms (definition lists)
% \begin{terms}*|[options](base)

\tl_new:N \g_terms_defaults_tl
\tl_new:N \g_terms_options_tl
\int_new:N \l_terms_int
\tl_new:N \l_terms_marker
\tl_new:N \l_terms_marker_i
\tl_new:N \l_terms_marker_ii
\tl_new:N \l_terms_marker_iii
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
            {2} {
                 \tl_if_empty:nTF {##1}
                     { \tl_set:Nn \l_terms_marker_iii {} }
                     { \tl_set:Nn \l_terms_marker_iii {##1\hskip\l_terms_marker_sep_skip} }
                }
         }
        \int_incr:N \l_tmpa_int
    }
}

\tl_set:Nn \l_terms_marker
{
    \int_compare:nT { \@listdepth = 1 }  { \l_terms_marker_i }
    \int_compare:nT { \@listdepth = 2 }  { \l_terms_marker_ii }
    \int_compare:nT { \@listdepth = 3 }  { \l_terms_marker_iii }
}

\keys_define:nn { terms }
{
    labeltype   .tl_set:N = \l_terms_label_type_tl,
    hyperlink   .bool_set:N = \l_terms_hyperlink_bool,
    offset      .skip_set:N = \l_terms_offset_skip,
    marker      .code:n = { \terms_define_marker:n {#1} },
    markersep   .skip_set:N = \l_terms_marker_sep_skip,
    enumerate   .bool_set:N = \l_terms_enumerate_bool,
    enummarker  .tl_set:N = \l_terms_enummarker_tl,
    base        .tl_set:N = \l_terms_base_tl,
    font        .tl_set:N = \l_terms_font_tl,
    color       .tl_set:N = \l_terms_color_tl,
    delimiter   .tl_set:N = \l_terms_delimiter_tl,
    labelwidth  .dim_set:N = \l_terms_label_width_dim,
    labelsep    .skip_set:N = \l_terms_label_sep_skip,
    labelvoffset    .skip_set:N = \l_terms_label_voffset_dim,
	itemindent  .dim_set:N = \l_terms_item_indent_dim,
	leftmargin  .dim_set:N = \l_terms_left_margin_dim,
    index       .bool_set:N = \l_terms_index_bool,
    indexcategory .tl_set:N = \l_terms_index_category_tl,
    indexsame   .bool_set:N = \l_terms_index_same_bool,
    topsep      .skip_set:N = \l_terms_top_sep_skip,
    itemsep     .skip_set:N  = \l_terms_item_sep_skip,
    style       .tl_set:N = \l_terms_style_tl,
    beforelist  .tl_set:N = \l_terms_before_list_tl,
    afterlist   .tl_set:N = \l_terms_after_list_tl,
    star        .tl_set:N = \l_terms_star_tl,
    vbar        .tl_set:N = \l_terms_vbar_tl
}

\NewDocumentCommand \TermsInitialize { m }
{
    \keys_set:nn { terms }{ #1 }
	\tl_gset:Nn \g_terms_defaults_tl { #1 }
}

\TermsInitialize{
	topsep=0.5\onelineskip,
    labeltype = default,
    hyperlink = false,
    offset = 0em,
    marker = {{},\textbullet},
    markersep = 0.5em,
    base = MM,
    font = \bfseries,
    color = black,
    delimiter = :\hfill,
    labelsep = 0.5em,
	leftmargin = 0pt,
	itemsep=.25ex,
    star = { itemsep=0ex },
    vbar = { delimiter=\hfill },
    enummarker = { \parbox{20pt}{\raggedleft\int_use:N \l_terms_int)}\hskip\l_terms_marker_sep_skip }
}

\cs_new:Npn \terms_index:n #1
{
    \bool_if:NTF \l_terms_index_same_bool
    {
        \tl_set:No \l_tmpa_tl
        {
            \string\termindexprint{\tl_to_str:V \l_terms_font_tl}{#1}
        }
        \tl_if_empty:NTF \l_terms_index_category_tl
        {
            \index{ \tl_use:N #1@\l_tmpa_tl }
        }{
            \index{ \tl_use:N \l_terms_index_category_tl!#1@\tl_use:N \l_tmpa_tl }
        }
    }{
        \tl_if_empty:NTF \l_terms_index_category_tl
        {
            \index{#1}
        }{
            \index{ \tl_use:N \l_terms_index_category_tl!#1 }
        }
    }
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

\cs_new:Npn \terms_label_macro_write:n #1
{
    % \tl_if_in:nnTF { #1 }{ ~ }
    % {
    %     \texttt{ \tl_to_str:n { #1 } }
    % }{
        \macroprint{#1}
        \bool_if:NT \l_terms_index_bool
        {
            \macroindex{#1}
            \tl_if_empty:NF \l_terms_index_category_tl
            {
                \exp_args:NnV \label_macro_index:nn { #1 } \l_terms_index_category_tl
            }
        }
    % }
}

\cs_new:Npn \label_macro_index:nn #1 #2
{
    \str_set:Nn \l_tmpa_str { #2 }
	\str_set:Nn \l_tmpb_str { #1 }
	\str_set:Nn \l_tmpb_tl { #1 }
	\regex_replace_all:nnN { ^\\ }{ } \l_tmpa_str
	\regex_replace_all:nnN { ^\\ }{ } \l_tmpb_str
	\regex_replace_all:nnN { \@ }{ ※ } \l_tmpb_str
	\regex_replace_all:nnN { \@ }{ ※ } \l_tmpb_tl
    \exp_args:Nooo \label_macro_index_write:nnn { \l_tmpa_str }{ \l_tmpb_str }{ \l_tmpb_tl }
}

\cs_new:Npn \label_macro_index_write:nnn #1#2#3
{
    \index{ #1!#2@\string\macroprint{#3} }
}

\NewDocumentCommand{\tlink}{m}{\hyperlink{#1}{#1}}

\cs_new:Npn \terms_label_default:n #1
{
    \int_gincr:N \l_terms_int
    \bool_if:NT \l_terms_index_bool { \terms_index:n {#1} }
    \group_begin:
        \color{\l_terms_color_tl}
        \l_terms_marker
        \l_terms_font_tl #1
        \bool_if:NT \l_terms_hyperlink_bool { \hypertarget{#1}{} }
    \group_end:
    \l_terms_delimiter_tl
}
\cs_new:Npn \terms_label_singleline:n #1
{
    \int_gincr:N \l_terms_int
    \bool_if:NT \l_terms_index_bool { \terms_index:n {#1} }
    \parbox[b]{\labelwidth}{
        \makebox[0pt][l]{
            \color{\l_terms_color_tl}
            \l_terms_marker
            \l_terms_font_tl #1
            \l_terms_delimiter_tl
        }
        \newline
    }
}
\cs_new:Npn \terms_label_multiline:n #1
{
    \int_gincr:N \l_terms_int
    \bool_if:NT \l_terms_index_bool { \terms_index:n {#1} }
    \hbox_set:Nn \l_tmpa_box
    {
        \parbox[t]{\labelwidth}{
            \raggedright
            \color{\l_terms_color_tl}
            \l_terms_font_tl #1
            \bool_if:NT \l_terms_hyperlink_bool { \hypertarget{#1}{} }
        }
    }
    \hbox_set:Nn \l_tmpb_box {\l_terms_font_tl A}
    \dim_set:Nn \l_tmpa_dim { \box_ht:N \l_tmpb_box }
    \raisebox{ \l_tmpa_dim + \l_terms_label_voffset_dim }{ \smash{\box_use:N \l_tmpa_box} }
}
\cs_new:Npn \terms_label_macro:n #1
{
    \int_gincr:N \l_terms_int
    \group_begin:
        \color{\l_terms_color_tl}
        \l_terms_marker
        \l_terms_font_tl
        \bool_if:NT \l_terms_hyperlink_bool { \hypertarget{#1}{} }
        \terms_label_macro_write:n {#1}
    \group_end:
    \l_terms_delimiter_tl
}
\cs_new:Npn \terms_label_macro_single:n #1
{
    \int_gincr:N \l_terms_int
    \parbox[b]{\labelwidth}{
        \makebox[0pt][l]{
            \color{\l_terms_color_tl}
            \l_terms_marker
            \l_terms_font_tl
            \bool_if:NT \l_terms_hyperlink_bool { \hypertarget{#1}{} }
			\terms_label_macro_write:n {#1}
            \l_terms_delimiter_tl
        }
        \newline
    }
}

% \cs_new:Npn \terms_label_adhoc:n #1 {}
% \cs_undefine:N \terms_label_adhoc:n

\cs_new:Npn \terms_label_type_set:n #1
{
    \skip_set:Nn \partopsep { 0pt }
    \skip_set_eq:NN \topsep \l_terms_top_sep_skip
    \skip_set_eq:NN \itemsep \l_terms_item_sep_skip
    \skip_set:Nn \listparindent { 0pt }
    \str_case:on { #1 }
    {
        { default }{
            \dim_compare:nTF { \l_terms_label_width_dim > 0pt}
            {
                \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            }{
                \dim_set_towidth:Nn \labelwidth { \l_terms_marker\l_terms_font_tl\l_terms_base_tl\l_terms_delimiter_tl }
            }
            \cs_set_eq:NN \makelabel \terms_label_default:n
        }
        { singleline }{
            \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            \skip_set_eq:NN \partopsep \hzparskip
            \cs_set_eq:NN \makelabel \terms_label_singleline:n
        }
        { multiline }{
            \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            \cs_set_eq:NN \makelabel \terms_label_multiline:n
        }
        { macro }{
            \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            \cs_set_eq:NN \makelabel \terms_label_macro:n
        }
        { macrosingle }{
            \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            \cs_set_eq:NN \makelabel \terms_label_macro_single:n
        }
		{ adhoc }{
            \dim_set_eq:NN \labelwidth \l_terms_label_width_dim
            \cs_set_eq:NN \makelabel \terms_label_adhoc:n
		}
    }
    \skip_set_eq:NN \labelsep \l_terms_label_sep_skip
   	\dim_set:Nn \leftmargin { \labelwidth+\labelsep }
    \int_compare:nT { \@listdepth = 1 }
    {
        \addtolength\leftmargin{ \l_terms_offset_skip }
    }
	\dim_compare:nT { \l_terms_left_margin_dim != 0pt }
	{
		\dim_set:Nn \leftmargin \l_terms_left_margin_dim
	}
	\dim_compare:nT { \l_terms_item_indent_dim != 0pt }
	{
		\dim_set:Nn \itemindent \l_terms_item_indent_dim
	}
}

\NewDocumentCommand \vitem { v }
{
    \item[{#1}]
}

\NewDocumentCommand \NewTerms { s m m }
{
    \IfBooleanTF{ #1 }{
        \RenewDocumentEnvironment
    }{
        \NewDocumentEnvironment
    }{ #2 }{ s t| O{} d() d<> }
    {
        \exp_args:Nno \keys_set:nn { terms }{ \g_terms_defaults_tl }
        \exp_args:Nno \keys_set:nn { terms }{ \g_terms_options_tl }
        \keys_set:nn { terms }{ #3 }
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
                \tl_set:Nn \l_terms_marker_ii { \l_terms_enummarker_tl }
                \int_gzero:N \l_terms_int
            }
            \IfValueT{ ##4 }
            {
                \tl_set:Nn \l_terms_base_tl { ##4 }
            }
            \IfValueT{ ##5 }
            {
                \tl_set:Nn \l_terms_index_category_tl { ##5 }
            }
            \terms_label_type_set:n { \l_terms_label_type_tl }
            \g_tex_text_style\l_terms_style_tl
        }
    }{
        \end{list}
        \l_terms_after_list_tl
    }

}

\NewDocumentCommand \RenewTerms { m m }
{
    \NewTerms*{ #1 }{ #2 }
}

\NewTerms{terms}{}

\NewTerms{UI}
{
    font = \sffamily\bfseries,
    color = darkgray,
}

\NewTerms{ signs }
{
    labeltype = multiline,
    labelwidth = 3em,
    delimiter = \hfill,
    itemsep = 1ex
}

% use \cellimg in tables or list labels
\dim_new:N \l_cell_image_voffset_dim
\NewDocumentCommand \CellImageOffset { m }
{
    \dim_set:Nn \l_cell_image_voffset_dim { #1 }
}
\CellImageOffset{ 1.5\onelineskip }
\NewDocumentCommand\cellimg{ O{\l_cell_image_voffset_dim} m }
{
    \group_begin:
    \hbox_set:Nn \l_tmpa_box 
    {
        \includegraphics[scale=\l_lineimg_scale_tl]{#2}
    }
    \dim_set:Nn \l_tmpa_dim { \box_ht:N \l_tmpa_box }
    \dim_set:Nn \l_tmpb_dim { \box_wd:N \l_tmpa_box }

    \parbox[t]{ \l_tmpb_dim }{
        \raisebox{ -\l_tmpa_dim + #1 }{ \box_use:N \l_tmpa_box }
        \bool_if:NT { \l_lineimg_showfilename_bool }
        {
            \newline \color{ImageName} \scriptsize
            \bool_if:NTF \g_image_counter_bool
            {
                \int_gincr:N \g_image_counter_int
                \int_use:N \g_image_counter_int 
            }{
                \tl_to_str:n { #2 }
            }
        }

    }
    \group_end:
}

\NewDocumentCommand \imgitem { r[] }
{
    \item[\cellimg{#1}]
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

\NewDocumentCommand \CloneTerms { mm }
{
    \NewDocumentEnvironment { #1 }{ O{} +b }
    {
        \hbox_set:Nn \l_tmpa_box
        {
            \begin{minipage}{\linewidth}
            \begin{termstmp} ##2 \end{termstmp}
            \end{minipage}
        }
        \begin{#2}[base=\l_tmpa_tl, ##1]
            ##2
        \end{#2}
    }{}
}

% ## option list

\int_new:N \l_opt_cnt_int
\newcommand*\optselected{☑}
\newcommand*\optunselected{☐}
\NewDocumentCommand \OptionLabel {}
{
    \int_gincr:N \l_opt_cnt_int
	\clist_if_in:NoTF \l_tmpa_clist {\int_use:N \l_opt_cnt_int}
	{
		\textsb{\optselected}
	}{
		\textsb{\optunselected}
	}
}

\newlist{oplist}{itemize}{3}
\NewDocumentEnvironment { options } { s O{} }
{
    \clist_set:Nn \l_tmpa_clist { #2 }
    \int_zero:N \l_opt_cnt_int
	\IfBooleanTF {#1} 
	{ 
		\setlist[oplist]{label=\OptionLabel}
	}{
		\setlist[oplist]{label=\OptionLabel, noitemsep}
	}
	\begin{oplist}
}{
	\end{oplist}
}

% ## \NewTerm
% \term*|[index position]{\LaTeX}

\tl_new:N \g_term_defaults_tl
\tl_new:N \g_term_options_tl
\tl_new:N \l_term_index_font_tl
\keys_define:nn { term }
{
    font        .tl_set:N = \l_term_font_tl,
    color       .tl_set:N = \l_term_color_tl,
    index       .bool_set:N = \l_term_index_bool,
    indexsame   .bool_set:N = \l_term_index_same_bool,
    breakable   .bool_set:N = \l_term_breakable_bool,
    star        .tl_set:N = \l_term_star_tl,
    vbar        .tl_set:N = \l_term_vbar_tl
}
\NewDocumentCommand \TermInitialize { m }
{
    \keys_set:nn { term }{ #1 }
	\tl_gset:Nn \g_term_defaults_tl { #1 }
}
\TermInitialize{
	font = \rmfamily,
    color = black,
    index = false,
    indexsame = false,
    breakable = true,
}
\NewDocumentCommand \TermSetup { o m }
{
	\IfValueTF { #1 }
	{
		\NewTerm*{ #1 }{ #2 }
	}{
    	\tl_gset:Nn \g_term_options_tl { #2 }
	}
}

\NewDocumentCommand \termindexprint { m m }
{
    \group_begin: #1 #2 \group_end:
}

\NewDocumentCommand \NewTerm { s m m }
{
    \IfBooleanTF{#1}{
        \RenewDocumentCommand
    }{
        \NewDocumentCommand
    } #2 { s t| o m o }
    {
		\mbox{} % to keep the baseline in parbox
        \exp_args:Nno \keys_set:nn { term }{ \g_term_defaults_tl }
        \exp_args:Nno \keys_set:nn { term }{ \g_term_options_tl }
        \keys_set:nn { term }{ #3 }
        \IfBooleanT{ ##1 }
        {
            \exp_args:Nno \keys_set:nn { term }{ \l_term_star_tl }
        }
        \IfBooleanT{ ##2 }
        {
            \exp_args:Nno \keys_set:nn { term }{ \l_term_vbar_tl }
        }
        \bool_if:NT \l_term_index_bool
        {
            \bool_if:NTF \l_term_index_same_bool
            {
                \tl_set:No \l_tmpa_tl
                {
                    \string\termindexprint{\tl_to_str:V \l_term_font_tl}{##4}
                }
                \IfValueTF { ##3 }
                {
                    \index{##3@\tl_use:N \l_tmpa_tl}
                }{
                    \index{##4@\tl_use:N \l_tmpa_tl}
                }
                \IfValueT { ##5 }
                {
                    \IfValueTF { ##3 }
                    {
                        \index{##5!##3@\tl_use:N \l_tmpa_tl}
                    }{
                        \index{##5!##4@\tl_use:N \l_tmpa_tl}
                    }
                }
            }{
                \IfValueTF { ##3 }
                {
                    \index{##3@##4}
                }{
                    \index{##4}
                }
                \IfValueT { ##5 }
                {
                    \IfValueTF { ##3 }
                    {
                        \index{##5!##3@##4}
                    }{
                        \index{##5!##4}
                    }
                }
            }
        }
        \bool_if:NTF \l_term_breakable_bool
        {
            \textcolor{\l_term_color_tl}{\l_term_font_tl ##4 }
        }{
            \mbox{\textcolor{\l_term_color_tl}{\l_term_font_tl ##4 }}
        }
    }
}

\NewDocumentCommand \RenewTerm { m m }
{
    \NewTerm*{ #1 }{ #2 }
}

\NewTerm{\term}{	
    star={font=\itshape}
}

% user interface
\NewTerm{\ui}
{
    font=\sffamily\mdseries,
    color=black,
	star={index=false}
}

% machine interface
\NewTerm{\mi}
{
    font=\sffamily\bfseries,
	color=darkgray,
    star={index=true}
}

%% menukeys package
\copymenustyle{RoundedKeys}{roundedkeys}
\changemenuelement{RoundedKeys}{sep}{\,+\,\allowbreak}
\renewmenumacro{\keys}[+]{RoundedKeys}
% to avoid conflict with that of tabto package
\tw@make@key@macro{\Tab} 
\cs_gset_eq:NN \tw@mk@Tab \tw@mk@tab@win
\NewDocumentCommand\Menu{m}{\menu{#1}\menuindex{#1}}
% to add the last item to the index
\NewDocumentCommand\menuindex{m}{ 
    \group_begin:
        \regex_split:nnN {\>}{#1} \l_tmpa_seq
        \seq_get_right:NN \l_tmpa_seq \l_tmpa_tl
        \tl_trim_spaces:N \l_tmpa_tl
        \regex_replace_all:nnN { \{(.*?)\} } { \1 } \l_tmpa_tl
        \tl_set:No \l_tmpb_tl { \string\termindexprint{\tl_to_str:n {\sffamily}}{\l_tmpa_tl} }
        \index{\tl_use:N \l_tmpa_tl @\tl_use:N \l_tmpb_tl}
    \group_end:
}

% ## annotate

\cs_set_eq:NN \Sup \textsuperscript
\cs_set_eq:NN \Sub \textsubscript

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
	index	    .bool_set:N = \l_annotate_index_bool,
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
    index=false,
	star={index=true},
}

\NewDocumentCommand \annotate { s O{} m }
{
	\group_begin:
		\AnnotateSetup{#2}
		\IfBooleanT {#1}
		{
			\exp_args:No \AnnotateSetup{\l_annotate_star}
		}
		\l_annotate_space
		\bool_if:NTF \l_annotate_breakable_bool
		{
			\exp_args:Nx \annotate_scope:n {\l_annotate_opening #3 \l_annotate_closing}
		}{
			\annotate_unbreakable:n {\l_annotate_opening #3 \l_annotate_closing}
		}
		\bool_if:NT \l_annotate_index_bool
		{
			\annotate_index:n {#3} % \index{#3}
		}
		\l_annotate_space
	\group_end:
}

\cs_new:Npn \annotate_index:n #1
{
    \group_begin:
    \tl_set:Nn \l_tmpa_tl { #1 }
    \tl_set:Nn \l_tmpb_tl { #1 }
    \regex_replace_all:nnN { ^\. }{ } \l_tmpa_tl
    \index{\tl_use:N \l_tmpa_tl @ \tl_use:N \l_tmpb_tl}
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

% ## index  ----------------------------------------------------------------------

\setlength\indexcolsep{2em}

\NewDocumentCommand \lettergroup { m }{ \textbf{#1} }
\NewDocumentCommand \BookmarkIndexHead {}
{
    \int_new:N \l_index_anchor_int
    \RenewDocumentCommand \lettergroup { m }
    {
        \int_incr:N \l_index_anchor_int
        \pdfbookmark[1]{##1}{\int_use:N \l_index_anchor_int}
        \textbf{##1}
    }
}

\bool_new:N \l_macro_index_bool
\NewDocumentCommand \MacroIndexEnable {}
{
    \bool_gset_true:N \l_macro_index_bool
}
\NewDocumentCommand \MacroIndexDisable {}
{
    \bool_gset_false:N \l_macro_index_bool
}
\NewDocumentCommand \IndexingEnable { s }
{
    \makeindex
    \TermSetup{index=true}
    \TermsSetup{index=true}
    \AnnotateSetup{index=true, star={index=false}}
    \MacroIndexEnable
    \IfBooleanT{ #1 }
    {
        \BookmarkIndexHead
    }
}

\NewDocumentCommand \IndexingDisable {}
{
    \TermSetup{index=false}
    \TermsSetup{index=false}
    \AnnotateSetup{index=false}
    \MacroIndexDisable
}

% ## circled numbers

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
    font=\footnotesize\sffamily\bfseries,    
    fgcolor=white,
    bgcolor=black,
    raise=-.5ex,
    sep=0pt,
    base=11
}

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

% # text boxes ___________________________________________________________

\NewTColorBox{FrameBox}{ s }
{
    colframe=gray, colback=white, after={\par\normalcolor},
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
    before~skip=0pt, after~skip=0pt, breakable=false, after={\par\normalcolor},
    colframe=white, colback=white, arc=0pt, boxrule=0pt,
    boxsep=0pt, top=0pt, bottom=0pt, left=1.5em, right=0em,
    borderline~west={1.5pt}{0pt}{orange},
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}
\NewTColorBox{RightBarBox}{ s }
{
    before~skip=0pt, after~skip=0pt, breakable=false, after={\par\normalcolor},
    colframe=white, colback=white, arc=0pt, boxrule=0pt,
    boxsep=0pt,  top=0pt, bottom=0pt, left=1.5em, right=1.5em,
    borderline~east={1.5pt}{0pt}{orange},
	IfBooleanTF={#1}{
		breakable=\l_bbox_breakable_adhoc_tl
	}{
		breakable=\l_bbox_breakable_default_tl
	}
}

\NewTColorBox{ShadowBox}{ s O{} }
{
    before~skip=0pt, after~skip=0pt, after={\par\normalcolor},
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
    before~skip=0pt, after~skip=0pt, after={\par\normalcolor},
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

\NewTColorBox{OpenShadeBox}{ s O{} }
{
    before~skip=0pt, after~skip=0pt, after={\par\normalcolor},
    boxrule=0pt, colframe=white, colback=white, arc=0pt,
    boxsep=0.25ex,  top=0.75ex, bottom=0.75ex, left=0em, right=0em,
    borderline~south={0.5pt}{0pt}{darkgray},
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
    before~skip=0pt, after~skip=0pt, after={\par\normalcolor},
    arc=0pt, boxrule=0pt,
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
    before~skip=0pt, after~skip=0pt, after={\par\normalcolor},
    boxrule=0.5pt, colframe=gray, colback=white, arc=0.5ex,
    boxsep=0.5ex, top=1.5ex, bottom=0.5ex, left=0.5em, right=0.5em,
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

\NewTColorBox{TabRuleBox}{ s O{} }
{
    opacityfill=0,
    before~skip=0pt, after~skip=0pt, after={\par\normalcolor},
    arc=0pt, boxrule=0pt, colback=white,
    boxsep=0.5ex,  top=1.5ex, bottom=0.75ex, left=0em, right=0em,
    borderline~north={0.5pt}{0pt}{darkgray},
    borderline~south={0.5pt}{0pt}{darkgray},
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

% ## \begin{BOUNDEDBOX}[options](title)
% \begin{BOUNDEDBOX}*: switch between breakable and unbreakable
% \begin{BOUNDEDBOX}^: narrow the space above

\tl_new:N \g_bounded_box_defaults_tl
\tl_new:N \g_bounded_box_options_tl

\keys_define:nn { BoundedBox }
{
    beforeskip 		    .skip_set:N = \l_bbox_before_skip,
    extraskip           .skip_set:N = \l_bbox_extra_skip,
    afterskip  		    .skip_set:N = \l_bbox_after_skip,
    type        		.tl_set:N = \l_bbox_type_tl,
    symbol      		.tl_set:N = \l_bbox_symbol_tl,
    signal      		.tl_set:N = \l_bbox_signal_tl,
    beforesignal		.tl_set:N = \l_bbox_before_signal_tl,
    aftersignal		    .tl_set:N = \l_bbox_after_signal_tl,
    style       		.tl_set:N = \l_bbox_style_tl,
    titlefont           .tl_set:N = \l_bbox_title_font_tl,
	breakable-default	.tl_set:N = \l_bbox_breakable_default_tl,
	breakable-adhoc		.tl_set:N = \l_bbox_breakable_adhoc_tl
}

\NewDocumentCommand \BoundedBoxInitialize { m }
{
    \keys_set:nn { BoundedBox }{ #1 }
	\tl_gset:Nn \g_bounded_box_defaults_tl { #1 }
}

\BoundedBoxInitialize {
    beforeskip = \hznulldim,
    extraskip = 0pt,
    afterskip = \hznulldim,
    type = ShadeBox,
    titlefont = \bfseries,
	breakable-default = true,
	breakable-adhoc = false
}

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
    \cs_set_eq:Nc \BBox {#1}
    \cs_set_eq:Nc \endBBox {end#1}
}

\NewDocumentCommand \NewBoundedBox { s m m }
{
    \IfBooleanTF{ #1 }
    {
        \RenewDocumentEnvironment
    }{
        \NewDocumentEnvironment
    }{ #2 }{ s t^ O{} d() +b }
    {
        \exp_args:Nno \keys_set:nn { BoundedBox }{ \g_bounded_box_defaults_tl }
        \exp_args:Nno \keys_set:nn { BoundedBox }{ \g_bounded_box_options_tl }
        \keys_set:nn { BoundedBox }{ #3 }
        \group_begin:
            \keys_set:nn { BoundedBox }{ ##3 }
			\IfValueT { ##4 }
			{
                \tl_set:Nn \l_bbox_signal_tl { ##4 }
			}
            \exp_args:Nx \bbox_type_set:n { \l_bbox_type_tl }
            \IfBooleanTF { ##2 }
            {
                \object_skip_before:n { \l_bbox_extra_skip }
            }{
                \object_skip_before:n { \l_bbox_before_skip }
            }
            \tl_if_empty:NTF \l_bbox_signal_tl
            {
				\IfBooleanTF { ##1 }
				{
                	\begin{BBox}*
                    \g_tex_text_style\l_bbox_style_tl\noindent ##5
                    \end{BBox}
				}{
					\begin{BBox}
                    \g_tex_text_style\l_bbox_style_tl\noindent ##5
                    \end{BBox}
				}
            }{
				\IfBooleanTF { ##1 }
				{
                	\begin{BBox}*[\l_bbox_symbol_tl\l_bbox_before_signal_tl\l_bbox_signal_tl\l_bbox_after_signal_tl]
                    \g_tex_text_style\l_bbox_style_tl\noindent ##5
                    \end{BBox}
				}{
                	\begin{BBox}[\l_bbox_symbol_tl\l_bbox_before_signal_tl\l_bbox_signal_tl\l_bbox_after_signal_tl]
                    \g_tex_text_style\l_bbox_style_tl\noindent ##5
                    \end{BBox}
				}
            }
            \object_skip_after:n { \l_bbox_after_skip }
        \group_end:
    }{}
}

\NewDocumentCommand \RenewBoundedBox { m m }
{
    \NewBoundedBox*{ #1 }{ #2 }
}

\keys_define:nn { admonition }
{
    danger      .tl_gset:N = \g_admonition_danger_tl,
    warning     .tl_gset:N = \g_admonition_warning_tl,
    caution     .tl_gset:N = \g_admonition_caution_tl,
    notice      .tl_gset:N = \g_admonition_notice_tl,
    note        .tl_gset:N = \g_admonition_note_tl,
}

% ## \AdmonitionSetup

\NewDocumentCommand \AdmonitionSetup { m }
{
    \keys_set:nn { admonition } {#1}
}

\AdmonitionSetup{
    danger=DANGER,
    warning=WARNING,
    caution=CAUTION,
    notice=NOTICE,
    note=NOTE
}

\NewBoundedBox{danger}{signal=\g_admonition_danger_tl, symbol={\img{AlertSymbol}~}}
\NewBoundedBox{warning}{signal=\g_admonition_warning_tl, symbol={\img{AlertSymbol}~}}
\NewBoundedBox{caution}{signal=\g_admonition_caution_tl}
\NewBoundedBox{notice}{signal=\g_admonition_notice_tl}
\NewBoundedBox{note}{signal=\g_admonition_note_tl}
\NewBoundedBox{reference}{style=\small}

% # tools to control documents __________________________________________________________

% ## tools to control objects, including images, lists and boxes

\newtcbox{\objectframe}{
    colframe=\g_object_frame_color,
    colback=white,
    boxrule=0.5pt,
    arc=0pt,
    boxsep=3pt,
    top=0pt, bottom=0pt, left=0pt, right=0pt
}

\cs_new:Npn \object_align:n #1
{
    \CaptionSetup{ align-short=#1, align=#1 }
    \ImageSetup{ align=#1 }
    \TableSetup{ align=#1 }
}

\keys_define:nn { HzObject }
{
    beforeskip  .skip_set:N = \g_object_before_skip,
    afterskip   .skip_set:N = \g_object_after_skip,
    framecolor  .tl_set:N = \g_object_frame_color,
    align       .code:n = { \object_align:n {#1} }
}

\NewDocumentCommand \ObjectSetup { m }
{
    \keys_set:nn { HzObject }{ #1 }
}

\cs_new:Npn \object_skip_before:n #1
{
    \dim_compare:nTF { #1 != \hznulldim }
    {
        \skip_set:Nn \l_tmpa_skip { #1 }
    }{
        \skip_set:Nn \l_tmpa_skip { \g_object_before_skip }
    }
    \vspace{ \l_tmpa_skip }
    \noindent
}

\cs_new:Npn \object_skip_after:n #1
{
    \dim_compare:nTF { #1 != \hznulldim }
    {
        \skip_set:Nn \l_tmpa_skip { #1 }
    }{
        \skip_set:Nn \l_tmpa_skip { \g_object_after_skip }
    }
    \vspace{ \l_tmpa_skip }
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

\ObjectSetup{ framecolor=gray }


% adjusting spaces

\NewDocumentCommand \EnlargePage { O{\onelineskip} }
{
    \enlargethispage{#1}
}

\NewDocumentCommand \skiplines { O{1} }
{
    \vspace{#1\onelineskip}
}

% ## cross-reference and hyperlink

\NewDocumentCommand \DecolorHyperlinks { s O {darkgray} O {\bfseries} }
{
	\hypersetup{plainpages=false, pdfborder={0 0 0}} 
	\IfBooleanTF {#1}
	{
		\hypersetup{colorlinks=true, allcolors=#2}
	}{
		\hypersetup{colorlinks=false}
	}
    \renewcommand{\theTitleReference}[2]{\textcolor{#2}{#3 ##2}}
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
        \href{https://#2}{\nolinkurl{#2}}
    }
}

%\path{file path}
%\def\flushleft{\setlength\topsep{0pt}\trivlist \raggedright\item\relax}

% ## editing tools
\newfontfamily\commentfont{UnDotum.ttf}[BoldFont=UnDotumBold.ttf]
\keys_define:nn { pending }
{
    color	.tl_set:N = \l_pending_color_tl,
    font	.tl_set:N = \l_pending_font_tl,
    hide	.bool_set:N = \l_pending_hide_bool
}

\NewDocumentCommand \PendingSetup { m }
{
    \keys_set:nn { pending } { #1 }
}

\PendingSetup{
    color=purple,
    font=\commentfont\small,
    hide=false
}

\NewDocumentCommand \pending { +m }
{
    \bool_if:NF \l_pending_hide_bool
    {
        \group_begin:
        \color{\l_pending_color_tl}
        \l_pending_font_tl #1
        \group_end:
    }
}

\NewDocumentEnvironment { Pending }{ +b }
{
    \pending{ #1 }
}{}

\NewDocumentCommand \HidePending {}
{
    \bool_set_true:N \l_pending_hide_bool
    \cs_set_eq:NN \listofqueries \relax
}

\NewDocumentCommand \ShowPending {}
{
    \bool_set_false:N \l_pending_hide_bool
}

\newcounter{query}
\renewcommand\thequery{<\arabic{query}>}
\newlistof{listofqueries}{loq}{Queries}
\newlistentry{query}{loq}{0}
\setcounter{loqdepth}{1}
\renewcommand*\cftqueryafterpnum{\bigskip}

\NewDocumentCommand \query { m o }
{
	\bool_if:NF \l_pending_hide_bool
    {
	    \refstepcounter{query}
        \mbox{} \hangfrom{
			\textcolor{ \l_pending_color_tl }{ \l_pending_font_tl \thequery }
		}
        \space
		\textcolor{\l_pending_color_tl}{ \l_pending_font_tl #1 }
        \IfValueTF {#2}
        {
            \addcontentsline{loq}{query}{ {\l_pending_font_tl\thequery\enspace #2} }
        }{
            \addcontentsline{loq}{query}{ {\l_pending_font_tl\thequery\enspace #1} }
        }
    }
}

% ## TSV

\clist_new:N \l_tsv_renderers_clist
\int_new:N \l_tsv_renderers_int

\keys_define:nn { TSV }
{
    csv         .bool_set:N = \l_csv_bool,
    heading     .code:n = { \cs_set_eq:NN \TSVheading #1 },
    space       .tl_set:N = \l_tsv_space_tl,
    tabs        .tl_set:N = \l_tsv_tabs_tl,
    renderers   .code:n = { \clist_set:Nn \l_tsv_renderers_clist {#1} },
    verbatim    .bool_set:N = \l_tsv_verb_bool,
    interline   .tl_set:N = \l_tsv_linterline_tl
}
\NewDocumentCommand \texttsv { m }{ #1 }
\NewDocumentCommand \TSVsetup { m }
{
    \keys_set:nn { TSV }{ #1 }
    \exp_args:NV \TabPositions{ \l_tsv_tabs_tl }
}

\TSVsetup{
    heading = \section,
    space = \tab,
    tabs = { 0pt, 0.25\linewidth, 0.5\linewidth, 0.75\linewidth },
    verbatim = false,
}

\ior_new:N \l_tsv_ior
\NewDocumentCommand \ReadTSV { m o }
{
    \group_begin:
    \IfValueT{#2}
    {
        \TSVsetup{ #2 }
    }
    \int_set:Nn \l_tsv_renderers_int {
        \clist_count:N \l_tsv_renderers_clist
    }
    \ior_open:Nn \l_tsv_ior { #1 }
        \ior_str_map_inline:Nn \l_tsv_ior
        {
			\regex_match:nnF { \`{3,} }{##1} % ``` to write comments in .tsv
			{
				\str_set:Nn \l_tmpa_str { ##1 }
				\bool_if:NTF \l_csv_bool
				{
					\seq_set_split:NnV \l_tmpa_seq { , } \l_tmpa_str
				}{
					\regex_replace_all:nnN { \t }{ | } \l_tmpa_str
					\seq_set_split:NnV \l_tmpa_seq { | } \l_tmpa_str
				}
				\tsv_render:N \l_tmpa_seq
			}
        }
    \ior_close:N \l_tsv_ior
    \group_end:
}

\cs_new:Npn \tsv_render:N #1
{
    \int_set:Nn \l_tmpa_int { \seq_count:N #1 }
	\int_compare:nTF { \l_tmpa_int = 1 }
	{
        \seq_pop:NN #1 \l_tmpa_str
        \str_if_empty:NF \l_tmpa_str
        {
			\bool_if:NTF \l_tsv_verb_bool
			{
				\tl_set:NV \l_tmpa_tl \l_tmpa_str
			}{
				\tl_set_rescan:Nno \l_tmpa_tl {}{ \l_tmpa_str }
			}
            \TSVheading{ \l_tmpa_tl }
        }
	}{
        \noindent
		\int_zero:N \l_tmpb_int
		\seq_map_inline:Nn #1
		{
            \int_incr:N \l_tmpb_int
			\tl_if_empty:nTF { ##1 }
			{
				\space
			}{
				\tsv_render_item:Nn \l_tmpb_int { ##1 }
			}
			\int_compare:nTF { \l_tmpb_int < \l_tmpa_int }
			{
				\mbox{}\l_tsv_space_tl
			}{	
				\par\l_tsv_linterline_tl
			}
		}
	}
}

\cs_new:Npn \tsv_render_item:Nn #1 #2
{
    \bool_if:NTF \l_tsv_verb_bool
    {
        \tl_set:Nn \l_tmpa_tl { #2 }
    }{
        \tl_set_rescan:Nnn \l_tmpa_tl {}{ #2 }
    }
    \int_compare:nTF { \l_tsv_renderers_int < #1 }
    {
        \exp_args:No \texttsv{\l_tmpa_tl}
    }{
        \exp_args:NNno \clist_item:Nn \l_tsv_renderers_clist { #1 } \l_tmpa_tl
    }
}

\NewDocumentEnvironment { CSVoutput }{ }
{
    \group_begin:
        \exp_args:Nx \verbatimoutput { \jobname.tsv }
}{
        \endverbatimoutput
    \group_end:
}

\NewDocumentCommand { \CSVinput }{ O{} }
{
    \ReadTSV{\jobname.tsv}[csv=true, #1] 
}

% ### switching between two sets of settings from outside

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
    \l_finalizer_final_tl
}
\NewDocumentCommand \FinalizerOff {}
{
    \l_finalizer_draft_tl
}
\FinalizerSetup{
	final = {\HidePending},
	draft = {\ShowImageFilename*\ShowPending}
}

% # source code _________________________________________________________________________
\NewDocumentCommand\winpath{m}
{ 
	\group_begin:
	\str_set:Nn \l_tmpa_str { #1 }
	\regex_replace_all:nnN { \s([\\\-\_]) } { \1\c{allowbreak} } \l_tmpa_str
	\tl_trim_spaces:N  \l_tmpa_str
	\texttt{\l_tmpa_str}
	\group_end:
}

% ## tex commands

\RenewDocumentCommand \verb {v}
{
    \texttt{#1}
}

\NewDocumentCommand \macroprint { m }
{
	\group_begin:
	\str_set:Nn \l_tmpa_str { #1 }
	\regex_replace_all:nnN { \s([\\\-\_\*\|\^\{\}\[\]]) }{ \1\c{allowbreak} } \l_tmpa_str
	\tl_trim_spaces:N  \l_tmpa_str
    \regex_replace_all:nnN { ※ }{ \@ } \l_tmpa_str
	\texttt{\l_tmpa_str}
	\group_end:
}

\NewDocumentCommand \macroindex { o m }
{
    \str_set:Nn \l_tmpb_str { #2 }
    \IfValueTF{#1}
    {
        \str_set:Nn \l_tmpa_str { #1 }
    }{
        \str_set:Nn \l_tmpa_str { #2 }
		\regex_replace_all:nnN { ^[\\\_\-\.] }{ } \l_tmpa_str
        \regex_replace_all:nnN { \@ }{ ※ } \l_tmpa_str
        \regex_replace_all:nnN { \@ }{ ※ } \l_tmpb_str
    }
    \exp_args:NVV \macro_index_write:nn { \l_tmpa_str }{ \l_tmpb_str }
}
\cs_new:Npn \macro_index_write:nn #1 #2
{
    \index{#1@\string\macroprint{#2}}
}

\NewDocumentCommand \macro { s o m }
{
    \macroprint{ #3 }
    \bool_if:NT \l_macro_index_bool
    {
        \IfBooleanF{#1}
        {
            \IfValueTF{#2}
            {
                \macroindex[#2]{#3}
            }{
                \macroindex{#3}
            }
        }
    }
}

% ## list with verbatim labels

\NewTerms{ macros }
{
    labeltype=macro,
    delimiter=\hfill,
    labelwidth=2.75em,
    leftmargin=3.35em,
    font=\ttfamily
}

% ## lyrics

\cs_new:Nn \obey_hspaces: { \penalty\z@\mbox{}\space }
\NewDocumentCommand \obeyhspaces { }
{
    \char_set_active_eq:nN {32} \obey_hspaces:
    \char_set_catcode_active:n {32}
}
\cs_new:Nn \obey_vlines: { \leavevmode\newline }
\NewDocumentCommand \obeyvlines { }
{
    \char_set_active_eq:nN {13} \obey_vlines:
    \char_set_catcode_active:n {13}
}
\NewDocumentEnvironment {lyrics} { }
{
    \obeyhspaces
    \obeyvlines
}{}

% ## listing

\NewBoundedBox{CodeBox}{style=\small}
\NewBoundedBox{ResultBox}{type=LeftBarBox, style=\sffamily\small}

\tl_set:Nx \l_code_file_tl { \jobname.vrb }
\dim_new:N \l_code_description_width_dim

\keys_define:nn { CODE }
{
    width       	.dim_set:N = \l_code_width_dim,
    beforeskip  	.skip_set:N = \l_code_before_skip,
    afterskip   	.skip_set:N = \l_code_after_skip,
    offset      	.skip_set:N = \l_code_raise_offset,
    offset-minted	.skip_set:N = \l_code_raise_offset_minted,
    font        	.code:n = { \code_verbatim_font:n {#1} },
    fontsize    	.tl_set:N = \l_code_fontsize_tl,
    linespacing 	.tl_set:N = \l_code_linespacing_tl,
    language    	.tl_set:N = \l_code_language_tl,
    boxed           .bool_set:N = \l_code_boxed_bool,
    codebox     	.tl_set:N = \l_code_codebox_tl,
    resultbox   	.tl_set:N = \l_code_resultbox_tl,
    file        	.code:n = { \tl_set:Nx \l_code_file_tl { #1 } },
    star            .tl_set:N = \l_code_star_tl
}

\cs_new:Npn \code_verbatim_font:n #1
{

    \sys_if_engine_luatex:TF
    {
        \ifLang { korean }
        {
            \def\m@mverbfont{\language=\l@nohyphenation #1}
        }{
            \def\m@mverbfont{#1}
        }
    }{
        \def\m@mverbfont{#1}
    }
}

\NewDocumentCommand \CodeSetup { m }
{
    \keys_set:nn { CODE }{ #1 }
	\bool_if:NT \g_minted_bool {
		\dim_compare:nT { \l_code_raise_offset != 0pt }
		{
			\skip_set_eq:NN \l_code_raise_offset \l_code_raise_offset_minted
		}
	}
    \tl_if_empty:NF \l_code_codebox_tl
    {
        \RenewBoundedBox{ CodeBox }{ type=\l_code_codebox_tl }
    }
    \tl_if_empty:NF \l_code_resultbox_tl
    {
        \RenewBoundedBox{ ResultBox }{ type=\l_code_resultbox_tl }
    }
    \bool_if:NT \g_minted_bool
    {
        \setminted{fontsize=\l_code_fontsize_tl}
    }
}

\protected\def\CRsymbol{\mbox{$\hookleftarrow$}}
\def\verbatimbreakchar{\CRsymbol}
\setlength\verbatimindent{0pt}
\setlength\ragrparindent{0pt}
\wrappingon

%\def\m@mverbfont{\ttfamily}
\CodeSetup{
    font=\ttfamily,
    fontsize=\small,
    width=0pt,
    beforeskip=\hznulldim,
    afterskip=\hznulldim,
    offset=-1.25\onelineskip,
    offset-minted=-0.75\onelineskip,
    linespacing=1.1,
    boxed=true,
    language=latex,
    star={language=text}
}

\NewDocumentEnvironment { codewrite }{ }
{
    \group_begin:
    \exp_args:Nx \verbatimoutput { \l_code_file_tl }
}{
    \endverbatimoutput
    \group_end:
}

\NewDocumentCommand \coderead { s O{} }
{
    \group_begin:
    \IfBooleanT{ #1 }
    {
        \exp_args:No \CodeSetup{ \l_code_star_tl }
    }
    \CodeSetup{ #2 }
    \setSpacing{ \l_code_linespacing_tl }
    \bool_if:NTF \l_code_boxed_bool
    {
        \dim_compare:nTF { \l_code_width_dim > 0pt }
        {
            \code_read_minipage:
        }{
            \code_read_box:
        }
    }{
        \code_read_verbatim:
    }

    \group_end:
}

\cs_new:Nn \code_read_verbatim:
{
    \l_code_fontsize_tl
    \bool_if:NTF \g_minted_bool
    {
        \exp_args:Noo \inputminted{ \l_code_language_tl }{ \l_code_file_tl }
    }{
        \verbatiminput{ \l_code_file_tl }
    }
}

\cs_new:Nn \code_read_minipage:
{
    \object_skip_before:n {\l_code_before_skip}
    \begin{minipage}[t]{\l_code_width_dim}
        \begin{CodeBox}[beforeskip=0pt, afterskip=0pt]
        \vspace{\l_code_raise_offset}\mbox{}
        \code_read_verbatim:
        \end{CodeBox}
    \end{minipage}
    \object_skip_after:n {\l_code_after_skip}
}

\cs_new:Nn \code_read_box:
{
    \int_compare:nTF { \@listdepth > 0 }
    {
        \skip_set:Nn \l_tmpa_dim { .75\l_code_raise_offset }
    }{
        \skip_set:Nn \l_tmpa_dim { \l_code_raise_offset }
    }
    \begin{CodeBox}[beforeskip=\l_code_before_skip, afterskip=\l_code_after_skip]
    \vspace{\l_tmpa_dim}\mbox{}
    \code_read_verbatim:
    \end{CodeBox}
}

\NewDocumentEnvironment { code }{}
{
    \group_begin:
    \exp_args:Nx \verbatimoutput { \l_code_file_tl }
}{
    \endverbatimoutput
    \group_end:

    \coderead
 }
\NewDocumentEnvironment { code* }{}
{
    \group_begin:
    \exp_args:Nx \verbatimoutput { \l_code_file_tl }
}{
    \endverbatimoutput
    \group_end:

    \coderead*
 }


\NewDocumentEnvironment { coderesult }{}
{
    \group_begin:
    \exp_args:Nx \verbatimoutput { \l_code_file_tl }
}{
    \endverbatimoutput
    \group_end:

    \coderead

    \bool_if:NTF \l_code_boxed_bool
    {
        \begin{ResultBox}
        \input{\l_code_file_tl}
        \end{ResultBox}
    }{
        \input{\l_code_file_tl}
    }
}

\NewDocumentCommand \codeinput {}
{
    \input{\l_code_file_tl}
}

\NewDocumentEnvironment { codedesc }{ O{} +b }
{
    \group_begin:
    \CodeSetup{#1}
    \dim_compare:nT { \l_code_width_dim = 0pt }
    {
       \dim_set:Nn \l_code_width_dim { .45\linewidth }
    }
    \dim_set:Nn \l_code_description_width_dim {
        \linewidth - \l_code_width_dim - 1em
    }
    \hbox_set:Nn \l_tmpa_box
    {
        \begin{minipage}{\linewidth}
            \begin{minipage}[t]{\l_code_width_dim}
                \setSpacing{ \l_code_linespacing_tl }
                \bool_if:NTF \l_code_boxed_bool
                {
                    \begin{CodeBox}[beforeskip=0pt, afterskip=0pt]
                    \vspace{\l_code_raise_offset}\mbox{}
                    \l_code_fontsize_tl
                    \bool_if:NTF \g_minted_bool
                    {
                        \exp_args:Nno \inputminted{ latex }{ \l_code_file_tl }
                    }{
                        \verbatiminput{ \l_code_file_tl }
                    }
                    \end{CodeBox}
                }{
                    \l_code_fontsize_tl
                    \bool_if:NTF \g_minted_bool
                    {
                        \exp_args:Nno \inputminted{ latex }{ \l_code_file_tl }
                    }{
                        \verbatiminput{ \l_code_file_tl }
                    }
                }
            \end{minipage}
            \hfill
            \begin{minipage}[t]{\l_code_description_width_dim}
                \vspace{.5\onelineskip}
                \g_tex_text_style \noindent #2
            \end{minipage}
        \end{minipage}
    }
    \dim_set:Nn \l_tmpa_dim { \box_ht:N \l_tmpa_box + \box_dp:N \l_tmpa_box }
    \dim_add:Nn \l_tmpa_dim { 2\onelineskip }
    \dim_set:Nn \l_tmpb_dim { \pagegoal - \pagetotal }
    \dim_compare:nTF { \l_tmpa_dim > \l_tmpb_dim }
	{
		\newpage
	}{
        \object_skip_before:n {\l_code_before_skip}
    }
    \box_use:N \l_tmpa_box
    \object_skip_after:n {\l_code_after_skip}
    \group_end:
}{}

% # document cover ______________________________________________________________________

\keys_define:nn { cover }
{
    topskip             .skip_set:N = \cover_top_skip,
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
    notelineskip        .skip_set:N = \cover_noteline_skip,
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
    topskip = .1\textheight,
    FontI = \sffamily\bfseries\color{darkgray},
    FontII = \sffamily\bfseries\color{darkgray},
    FontSizeI = \Huge,
    FontSizeII = \huge,
    FontSizeIII = \LARGE,
    FontSizeIV = \Large,
    TitleAlign = \raggedright,
    ProductImage = cover_image,
    AfterFront = \clearpage, %\cleartorecto,
    BeforeBack = \clearpage, %\cleartoverso,
	BlankFront = false,
	BlankBack = false,
    notelineskip = .25\onelineskip
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
	}{
		\begin{IfVartwoEnlarge}
			\setSpacing{1}
            \noindent
			\tl_if_empty:NF \cover_image_logo_front
			{
				\includegraphics{\cover_image_logo_front}
                \bool_if:NT \l_image_showfilename_bool
                {
                    \tl_set:Nx \l_tmpa_tl { \cover_image_logo_front }
                    \group_begin:
                    \color{ImageName} \scriptsize \tl_to_str:N \l_tmpa_tl
                    \group_end:
                }
			}
			\mbox{}\par\vspace{\cover_top_skip}
			\begin{minipage}{\linewidth}
                    \noindent
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
                    \bool_if:NT \l_image_showfilename_bool
                    {
                        \tl_set:Nx \l_tmpa_tl { \cover_image_product }
                        \legend{\tl_to_str:N \l_tmpa_tl}
                    }
				\end{center}
			}
			\vfill
			\begin{flushright}
                \cover_font_ii
                \CoverFontSize{3} \cover_doc_type
                \smallskip \par
				\CoverFontSize{4} \cover_pub_year 
                \tl_if_empty:NF \cover_revision
                {
                    \hspace{0.5em}|\hspace{0.5em} \cover_revision
                }
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
			\setSpacing{1}
			\mbox{}\vfill
            \noindent \cover_font_ii
			\tl_if_empty:NTF \cover_image_logo_back
			{
                \tl_if_empty:NF \cover_note
                {
                    {\small\cover_note} \\
                }
			}{
                \begin{IllustImage}[
                        afterskip=-\cover_noteline_skip,
                        position=left,
                        frame=false, 
                        valign=b
                    ]{ \cover_image_logo_back }
                    \small\cover_note
                \end{IllustImage}\par
			}
			\raisebox{\cover_noteline_skip}{\rule{\headwidth}{0.5pt}} \\
			© \space \cover_pub_year \space \cover_manufacturer \\
			\cover_manufacturer_address
		\end{IfVartwoEnlarge}
	}
}


\NewDocumentCommand\tounit{mm}
{
    \macroprint{#1} \space=\space \dim_to_decimal_in_unit:nn { #1 }{ 1#2 }\,#2
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

% for Cloche  * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
\NewDocumentCommand\htmlbegin{}{}
\NewDocumentCommand\htmlend{}{}
\NewDocumentEnvironment{html}{+b}{}{}

% default settings * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

% sectional divisions
\setsecnumdepth{section}
\settocdepth{subsection}
\HeadingSetup{ paragraphstyle=interval }

% header & footer
\nouppercaseheads

% TOC
%\setlength{\cftchapternumwidth}{4.0em}
%\setlength\cftsectionnumwidth{2.5em}
%\setlength\cftsubsectionnumwidth{3.5em}

% justification
% Use \RaggedRight instead of \raggedright when using bidi
\raggedbottom % \flushbottom \sloppy

% colors
\definecolor{backgray}{gray}{0.9}

% cross-reference
\renewcommand{\chapterrefname}{\chaptername~}
\renewcommand{\tablerefname}{\tablename}
\renewcommand{\figurerefname}{\figurename}

\NewDocumentCommand{\quotes}{sm}{\IfBooleanTF{#1}{`#2'}{``#2''}}

\LoadStyleset

\endinput