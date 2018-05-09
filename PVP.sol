pragma solidity ^0.4.0;

contract Voting 
{
    
    struct VOTER
    {
        uint8 Weight;
        bool b_Voted;
        uint8 Vote;
        address Delegate;
    }
    
    struct CANDIDATE
    {
        uint VoteCount;
    }
    
    address m_ContractMaker;
    mapping(address => VOTER) m_Voters;
    CANDIDATE[] m_Candidates;
    
    // Create a new voting with $(_NumCandidate) different candidate.
    function Voting(uint256 _NumCandidate) public
    {
        m_ContractMaker = msg.sender;
        m_Voters[m_ContractMaker].b_Voted = false;
        m_Voters[m_ContractMaker].Weight = 1;
        m_Candidates.length = _NumCandidate;
        
    }
    
    // Give $(ToVoter) the wight to vote on this ballot.
    function GiveWeightToVote(address ToVoter) public
    {
        // Give the right only be called by $(m_ContractMaker).
        if(msg.sender != m_ContractMaker || m_Voters[ToVoter].b_Voted)
            return;
        m_Voters[ToVoter].Weight = 1;
    }
    
    // Delegate your right to the voter $(To).
    function Delegate(address To) public
    {
        VOTER storage l_Sender = m_Voters[msg.sender];
        
        if(l_Sender.b_Voted)
            return;
            
        // find last delegated address
        while(m_Voters[To].Delegate != address(0) && m_Voters[To].Delegate != msg.sender)
            To = m_Voters[To].Delegate;
        
        if(To == msg.sender)
            return;
            
        l_Sender.b_Voted = true;
        l_Sender.Delegate = To;
        VOTER storage l_Reciver = m_Voters[To];
        
        if(l_Reciver.b_Voted)
            m_Candidates[l_Reciver.Vote].VoteCount += l_Sender.Weight;
        else
            l_Reciver.Weight += l_Sender.Weight;
    }
    
    // voting only one vote to Candidate $(ToCandidate)
    function Vote(uint8 ToCandidate) public
    {
        VOTER storage l_Sender = m_Voters[msg.sender];
        
        if(l_Sender.b_Voted || ToCandidate >= m_Candidates.length)
            return;
            
        l_Sender.Weight -= 1;
        
        if(l_Sender.Weight == 0)
        {
            l_Sender.b_Voted = true;
            l_Sender.Vote = ToCandidate;
        }
        
        m_Candidates[ToCandidate].VoteCount += 1;
    }
    
    function WinningCandidate() public constant returns (uint8 _WinningCandidate)
    {
        uint256 l_WinningVoteCount = 0;
        
        for(uint8 l_Prop = 0 ; l_Prop < m_Candidates.length ; l_Prop++)
            if(m_Candidates[l_Prop].VoteCount > l_WinningVoteCount)
            {
                l_WinningVoteCount = m_Candidates[l_Prop].VoteCount;
                _WinningCandidate = l_Prop;
            }
    }
    
    function isWeight(address Addr) public constant returns (uint8 _NowWeight)
    {
        _NowWeight = m_Voters[Addr].Weight;
    }
    
    function isVoted(address Addr) public constant returns (bool _NowVoted)
    {
        _NowVoted = m_Voters[Addr].b_Voted;
    }
}