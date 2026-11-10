local function QuestionParser(decoded)
    local root = decoded[1] or decoded
    local results = {}
    local currentQuestion = ""

    local function HasType(tbl, target)
        if not tbl.type then return false end

        for _, value in ipairs(tbl.type) do
            if value == target then
                return true
            end
        end

        return false
    end

    local function GetText(tbl, includeSlots)
        local output = {}

        local function Search(node)
            if type(node) ~= "table" then return end

            if node.element == "text" then
                table.insert(output, node.text or "")
            elseif node.element == "slot" and includeSlots then
                table.insert(output, " ___")
            end

            if type(node.content) == "table" then
                for _, child in ipairs(node.content) do
                    Search(child)
                end
            end
        end

        Search(tbl)

        return table.concat(output)
    end

    local function GetSlots(tbl)
        local slots = {}

        local function Search(node)
            if type(node) ~= "table" then return end

            if node.element == "slot" then
                table.insert(slots, node)
            end

            if type(node.content) == "table" then
                for _, child in ipairs(node.content) do
                    Search(child)
                end
            end
        end

        Search(tbl)

        return slots
    end

    local function GetAnswers(groupID)
        local answers = {}

        local group = root.input.card_groups[groupID]
        if not group then return answers end

        for _, ref in ipairs(group.card_refs) do
            local card = root.input.cards[ref]

            if card then
                table.insert(answers, GetText(card, false))
            end
        end

        return answers
    end

    local function ProcessPartGroup(partGroup)
        local questionParts = {}
        local answerParts = {}

        local function Search(node)
            if type(node) ~= "table" then return end

            if node.element == "group" then
                if HasType(node, "question-part") then
                    table.insert(questionParts, node)
                elseif HasType(node, "answer-part") then
                    table.insert(answerParts, node)
                end
            end

            if type(node.content) == "table" then
                for _, child in ipairs(node.content) do
                    Search(child)
                end
            end
        end

        Search(partGroup)

        for _, part in ipairs(questionParts) do
            currentQuestion = GetText(part, false)
        end

        for _, part in ipairs(answerParts) do
            local slots = GetSlots(part)
            local prompt = GetText(part, true)

            for _, slot in ipairs(slots) do
                table.insert(results, {
                    question = currentQuestion,
                    prompt = prompt,
                    answers = GetAnswers(slot.accept)
                })
            end
        end
    end

    local function SearchPartGroups(node)
        if type(node) ~= "table" then return end

        if node.element == "part-group" then
            ProcessPartGroup(node)
            return
        end

        if type(node.content) == "table" then
            for _, child in ipairs(node.content) do
                SearchPartGroups(child)
            end
        end
    end

    SearchPartGroups(root.layout)

    return results
end

return QuestionParser