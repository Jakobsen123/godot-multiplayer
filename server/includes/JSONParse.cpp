#include <includes/nlohmann/json.hpp>
#include <string>
#include "includes/connection.h"

class JSONParse
{
public:
    static bool Parse(const std::string &text, Client &out)
    {
        auto parsedJSON = nlohmann::json::parse(text, nullptr, false);
        try
        {
            out.name = parsedJSON.at("position");
            out.position = Vector3(parsedJSON.at("x"), parsedJSON.at("y"), parsedJSON.at("z"));
            out.rotation = parsedJSON.at("rotation");
            return true;
        }
        catch (const nlohmann::json::exception &e)
        {
            return false;
        }
    }
};