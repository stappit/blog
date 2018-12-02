--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend, mconcat, (<>))
import           Data.Maybe (fromMaybe)
import           Hakyll
import           Text.Pandoc (WriterOptions (..), HTMLMathMethod (MathJax))
import           Text.Pandoc.Options
import qualified Data.Set as S

--------------------------------------------------------------------------------
main :: IO ()
main = hakyll $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match "js/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "data/*" $ do
        route   idRoute
        compile copyFileCompiler

    match (fromList ["about.markdown", "contact.markdown", "404.md"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    -- build up tags 
    tags <- buildTags postsGlob (fromCapture "tags/*.html")
    tagsRules tags $ \tag pattern -> do 
        route idRoute 
        compile $ do 
            posts <- recentFirst =<< loadAll pattern 
            let ctx = constField "title" ("Posts tagged \"" ++ tag ++ "\"") 
                        `mappend` listField "posts" postCtx (return posts) 
                        `mappend` defaultContext 
            makeItem "" 
                    >>= loadAndApplyTemplate "templates/tag.html" ctx 
                >>= loadAndApplyTemplate "templates/default.html" ctx 
                >>= relativizeUrls

    -- build up categories 
    categories <- buildCategories postsGlob (fromCapture "categories/*.html")
    tagsRules categories $ \tag pattern -> do 
        route idRoute 
        compile $ do 
            posts <- recentFirst =<< loadAll pattern 
            let ctx = constField "title" ("Posts in category \"" ++ tag ++ "\"") 
                        `mappend` listField "posts" postCtx (return posts) 
                        `mappend` defaultContext 
            makeItem "" 
                >>= loadAndApplyTemplate "templates/tag.html" ctx 
                >>= loadAndApplyTemplate "templates/default.html" ctx 
                >>= relativizeUrls

    match postsGlob $ do
        route $ setExtension "html"
        compile $ postCompiler
            >>= saveSnapshot "teaser"
            >>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags categories)
            >>= applyFilter postFilters
            >>= saveSnapshot "content"
            >>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags categories <> metaKeywordContext <> metaDescriptionContext)
            >>= relativizeUrls

    {-match "drafts/*" $ do-}
        {-route $ setExtension "html"-}
        {-compile $ pandocMathCompiler-}
            {->>= loadAndApplyTemplate "templates/post.html"    (postCtxWithTags tags categories)-}
            {->>= applyFilter postFilters-}
            {->>= loadAndApplyTemplate "templates/default.html" (postCtxWithTags tags categories)-}
            {->>= relativizeUrls-}

    match "posts/**.stan" $ version "raw" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**.Rmd" $ version "raw" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**.svg" $ version "raw" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**.jp*g" $ version "raw" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**.png" $ version "raw" $ do
        route   idRoute
        compile copyFileCompiler

    match "posts/**.lhs" $ version "raw" $ do
        route   idRoute
        compile getResourceBody

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll (postsGlob .&&. hasNoVersion)
            let archiveCtx = mconcat
                  [
                    listField "posts" postCtx (return posts)
                  , constField "title" "Archives"           
                  , defaultContext
                  ]

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (take 5) . recentFirst =<< loadAll (postsGlob .&&. hasNoVersion)
            let indexCtx = mconcat
                    [ constField "title" "Home"
                    , listField "posts" (teaserField "teaser" "teaser" <> postCtx) (return posts) 
                    , defaultContext
                    ]

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

    create ["atom.xml"] $ do
        route idRoute
        compile $ do
            let feedCtx = postCtx `mappend` bodyField "description"
            posts <- fmap (take 10) . recentFirst =<< loadAllSnapshots (postsGlob .&&. hasNoVersion) "content"
            renderAtom myFeedConfiguration feedCtx posts

--------------------------------------------------------------------------------
postsGlob = "posts/**.md" :: Pattern

postCtx :: Context String
postCtx = mconcat
    [ dateField "date" "%e %B, %Y"
    , constField "author" "Brian"
    , defaultContext
    ]

postCtxWithTags :: Tags -> Tags -> Context String 
postCtxWithTags tags cats = mconcat
    [
      tagsField "tags" tags
    , categoryField "cat" cats
    , postCtx
    ]

postWriterOptions :: WriterOptions
postWriterOptions = defaultHakyllWriterOptions {
      writerExtensions = newExtensions
    , writerHTMLMathMethod = MathJax ""
    , writerHtml5 = True
    }
  where
      mathExtensions = [ Ext_tex_math_dollars
                             , Ext_tex_math_double_backslash
                             , Ext_latex_macros
                             ]
      defaultExtensions = writerExtensions defaultHakyllWriterOptions
      newExtensions = foldr S.insert defaultExtensions mathExtensions

postWriterOptionsToc :: WriterOptions
postWriterOptionsToc = postWriterOptions{
      writerTableOfContents = True
    , writerTOCDepth = 2
    , writerTemplate = Just "$if(toc)$<div id=\"toc\">$toc$</div>$endif$\n$body$"
    } 

postCompiler = do
    ident <- getUnderlying 
    toc   <- getMetadataField ident "withtoc"
    let writerSettings = case toc of      
            Just "true" -> postWriterOptionsToc
            Just "yes"  -> postWriterOptionsToc
            Just _      -> postWriterOptions
            Nothing     -> postWriterOptions    
    pandocCompilerWith defaultHakyllReaderOptions writerSettings

----------------------------------------------------------------------------------
applyFilter :: (Monad m, Functor f) => (String -> String) -> f String -> m (f String)
applyFilter g fs = return . fmap g $ fs

preFilters :: String -> String
preFilters = noAtxLhs

postFilters :: String -> String
postFilters = mathjaxFix

mathjaxFix = replaceAll "><span class=\"math" (" class=\"mathjaxWide\"" ++)

noAtxLhs = replaceAll "^#" (" "++)

metaKeywordContext :: Context String
-- can be reached using $metaKeywords$ in the templates
-- Use the current item (markdown file)
metaKeywordContext = field "keywords" $ \item -> do
  -- tags contains the content of the "tags" metadata
  -- inside the item (understand the source)
  tags <- getMetadataField (itemIdentifier item) "tags"
  return $ fromMaybe "" tags

metaDescriptionContext :: Context String
-- can be reached using $metaKeywords$ in the templates
-- Use the current item (markdown file)
metaDescriptionContext = field "tldr" $ \item -> do
  -- tags contains the content of the "tags" metadata
  -- inside the item (understand the source)
  tldr <- getMetadataField (itemIdentifier item) "tldr"
  return $ fromMaybe "" tldr

----------------------------------------------------------------------------------
myFeedConfiguration :: FeedConfiguration
myFeedConfiguration = FeedConfiguration
    { feedTitle       = "Brian Callander"
    , feedDescription = "Lots of exercise solutions to statistics books, some data analyses, and a bit of running."
    , feedAuthorName  = "Brian Callander"
    , feedAuthorEmail = "briancallander+blog@gmail.com"
    , feedRoot        = "http://www.briancallander.com"
    }
