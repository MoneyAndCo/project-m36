{-# LANGUAGE TypeSynonymInstances, FlexibleInstances #-}
{-# OPTIONS_GHC -fno-warn-orphans #-}
module TutorialD.Interpreter.TransGraphRelationalOperator where
import ProjectM36.TransGraphRelationalExpression
import ProjectM36.TransactionGraph
import qualified ProjectM36.Client as C

import TutorialD.Interpreter.Base
import TutorialD.Interpreter.RelationalExpr

import Text.Megaparsec
import Text.Megaparsec.Text

import qualified Data.Text as T

instance RelationalMarkerExpr TransactionIdLookup where
  parseMarkerP = string "@" *> transactionIdLookupP
    
data TransGraphRelationalOperator = ShowTransGraphRelation TransGraphRelationalExpr

transactionIdLookupP :: Parser TransactionIdLookup
transactionIdLookupP =  (TransactionIdLookup <$> uuidP) <|>
                        (TransactionIdHeadNameLookup <$> identifier)
                        
transGraphRelationalOpP :: Parser TransGraphRelationalOperator                     
transGraphRelationalOpP = showTransGraphRelationalOpP
  
showTransGraphRelationalOpP :: Parser TransGraphRelationalOperator
showTransGraphRelationalOpP = do
  reservedOp ":showtransgraphexpr"
  ShowTransGraphRelation <$> relExprP  
  
evalTransGraphRelationalOp :: C.SessionId -> C.Connection -> TransGraphRelationalOperator -> IO TutorialDOperatorResult
evalTransGraphRelationalOp sessionId conn (ShowTransGraphRelation expr) = do
  res <- C.executeTransGraphRelationalExpr sessionId conn expr
  case res of
    Left err -> pure $ DisplayErrorResult $ T.pack (show err)
    Right rel -> pure $ DisplayRelationResult rel
    