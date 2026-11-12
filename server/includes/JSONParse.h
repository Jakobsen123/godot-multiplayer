#include "nlohmann/json.hpp"
#include <string>
#include "connection.h"

class JSONParse
{
public:
    static bool Parse(const std::string &text, Client &out)
    {
        auto parsedJSON = nlohmann::json::parse(text, nullptr, false);
        try
        {
            out.name = parsedJSON.at("name").get<std::string>();

            const auto &pos = parsedJSON.at("position");
            out.position = Vector3{pos.at("x").get<float>(),
                                   pos.at("y").get<float>(),
                                   pos.at("z").get<float>()};

            out.rotation = parsedJSON.at("rotation").get<float>();
            return true;
            return true;
        }
        catch (const nlohmann::json::exception &e)
        {
            return false;
        }
    }
};